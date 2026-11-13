package com.giladtamam.zigdash

import android.app.Activity
import android.os.Handler
import android.os.Looper
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * ZigDash Pro through Google Play Billing (docs/design/history-2.7.md), in
 * the Play build only: the foss build has a stub and no billing library.
 *
 * Channel "zigdash/billing":
 *  - status -> "unlocked" | "locked" | "pending" | "unavailable"
 *  - offer  -> what Play sells Pro for now: price, priceMicros, currency,
 *              and during a discount offer fullPriceMicros, percent, endMs
 *              and offerId (3.4.4); null when unknown
 *  - buy    -> the status after Play's purchase sheet closes, or "changed"
 *              when the price that was shown (offerId, priceMicros) is no
 *              longer what Play sells, in which case nothing was launched
 *
 * Nothing is stored by ZigDash: Play's own purchase record is the truth, and
 * a purchase restores on a new device by asking Play again.
 */
class ProBilling(private val activity: Activity, messenger: BinaryMessenger) :
    PurchasesUpdatedListener {

    private val main = Handler(Looper.getMainLooper())
    private var pendingBuy: MethodChannel.Result? = null

    private val client: BillingClient = BillingClient.newBuilder(activity)
        .setListener(this)
        .enablePendingPurchases(
            PendingPurchasesParams.newBuilder().enableOneTimeProducts().build()
        )
        .enableAutoServiceReconnection()
        .build()

    init {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "status" -> status { reply(result, it) }
                "buy" -> buy(
                    result,
                    call.argument<String>("offerId"),
                    call.argument<Number>("priceMicros")?.toLong(),
                )
                "offer" -> offer { o -> main.post { result.success(o) } }
                "token" -> token { reply(result, it) }
                else -> result.notImplemented()
            }
        }
    }

    private fun reply(result: MethodChannel.Result, value: String) =
        main.post { result.success(value) }

    private fun connected(block: (Boolean) -> Unit) {
        if (client.isReady) {
            block(true)
            return
        }
        client.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(r: BillingResult) =
                block(r.responseCode == BillingClient.BillingResponseCode.OK)

            override fun onBillingServiceDisconnected() {}
        })
    }

    private fun product(block: (ProductDetails?) -> Unit) {
        val params = QueryProductDetailsParams.newBuilder().setProductList(
            listOf(
                QueryProductDetailsParams.Product.newBuilder()
                    .setProductId(PRODUCT)
                    .setProductType(BillingClient.ProductType.INAPP)
                    .build()
            )
        ).build()
        client.queryProductDetailsAsync(params) { r, details ->
            block(
                if (r.responseCode == BillingClient.BillingResponseCode.OK)
                    details.productDetailsList.firstOrNull()
                else null
            )
        }
    }

    /**
     * The way Pro is sold to this user right now: a discount offer whose
     * time window holds, else the plain buy option. A rental is not Pro.
     * Null when Play lists nothing this app can sell.
     */
    private fun current(details: ProductDetails): ProductDetails.OneTimePurchaseOfferDetails? {
        val all = details.oneTimePurchaseOfferDetailsList
            ?.filter { it.rentalDetails == null }
            .orEmpty()
        if (all.isEmpty()) return details.oneTimePurchaseOfferDetails
        val now = System.currentTimeMillis()
        val discounted = all.filter { o ->
            val w = o.validTimeWindow
            o.discountDisplayInfo != null && o.fullPriceMicros != null &&
                (w == null || (now >= (w.startTimeMillis ?: Long.MIN_VALUE) &&
                    now < (w.endTimeMillis ?: Long.MAX_VALUE)))
        }
        return discounted.minByOrNull { it.priceAmountMicros }
            ?: all.firstOrNull { it.discountDisplayInfo == null }
            ?: all.first()
    }

    /** Pro's price for this user, with the sale's details during one. */
    private fun offer(done: (Map<String, Any?>?) -> Unit) = connected { ok ->
        if (!ok) {
            done(null)
            return@connected
        }
        product { details ->
            val o = details?.let(::current)
            if (o == null) {
                done(null)
                return@product
            }
            val sale = o.discountDisplayInfo != null && o.fullPriceMicros != null
            done(
                mapOf(
                    "price" to o.formattedPrice,
                    "priceMicros" to o.priceAmountMicros,
                    "currency" to o.priceCurrencyCode,
                    "fullPriceMicros" to if (sale) o.fullPriceMicros else null,
                    "percent" to if (sale) o.discountDisplayInfo?.percentageDiscount else null,
                    "endMs" to if (sale) o.validTimeWindow?.endTimeMillis else null,
                    "offerId" to if (sale) o.offerId else null,
                )
            )
        }
    }

    /** Owned (and acknowledged), pending, or for sale. */
    private fun status(done: (String) -> Unit) = connected { ok ->
        if (!ok) {
            done("unavailable")
            return@connected
        }
        client.queryPurchasesAsync(
            QueryPurchasesParams.newBuilder()
                .setProductType(BillingClient.ProductType.INAPP).build()
        ) { r, purchases ->
            if (r.responseCode != BillingClient.BillingResponseCode.OK) {
                done("unavailable")
                return@queryPurchasesAsync
            }
            val own = purchases.filter { PRODUCT in it.products }
            own.forEach(::acknowledge)
            when {
                own.any { it.purchaseState == Purchase.PurchaseState.PURCHASED } ->
                    done("unlocked")
                own.any { it.purchaseState == Purchase.PurchaseState.PENDING } ->
                    done("pending")
                else -> product { done(if (it == null) "unavailable" else "locked") }
            }
        }
    }

    /** The purchase token of an owned Pro, for the ZigDash relay (3.1); "" if none. */
    private fun token(done: (String) -> Unit) = connected { ok ->
        if (!ok) {
            done("")
            return@connected
        }
        client.queryPurchasesAsync(
            QueryPurchasesParams.newBuilder()
                .setProductType(BillingClient.ProductType.INAPP).build()
        ) { r, purchases ->
            val owned = purchases.firstOrNull {
                PRODUCT in it.products && it.purchaseState == Purchase.PurchaseState.PURCHASED
            }
            done(if (r.responseCode == BillingClient.BillingResponseCode.OK && owned != null) owned.purchaseToken else "")
        }
    }

    /**
     * Launches Play's sheet for the price the screen showed: the discount
     * offer [offerId] at [priceMicros], or the plain price. Play is asked
     * again first, and when the fresh answer is a different price (a sale
     * ended, or began, in between) nothing is launched and "changed" goes
     * back, so the buyer is never charged another price than the one shown.
     */
    private fun buy(result: MethodChannel.Result, offerId: String?, priceMicros: Long?) = connected { ok ->
        if (!ok) {
            reply(result, "unavailable")
            return@connected
        }
        product { details ->
            if (details == null) {
                reply(result, "unavailable")
                return@product
            }
            val now = current(details)
            val nowId = if (now?.discountDisplayInfo != null) now.offerId else null
            if (priceMicros != null &&
                (now == null || now.priceAmountMicros != priceMicros || nowId != offerId)
            ) {
                reply(result, "changed")
                return@product
            }
            main.post {
                pendingBuy?.success("locked")
                pendingBuy = result
                val one = BillingFlowParams.ProductDetailsParams.newBuilder()
                    .setProductDetails(details)
                // Play's new product model wants the token of the option
                // being bought; the old single-offer answer has none to give.
                val token = now?.offerToken
                if (!details.oneTimePurchaseOfferDetailsList.isNullOrEmpty() &&
                    !token.isNullOrEmpty()
                ) {
                    one.setOfferToken(token)
                }
                val params = BillingFlowParams.newBuilder().setProductDetailsParamsList(
                    listOf(one.build())
                ).build()
                val r = client.launchBillingFlow(activity, params)
                if (r.responseCode != BillingClient.BillingResponseCode.OK) {
                    pendingBuy = null
                    result.success("locked")
                }
            }
        }
    }

    override fun onPurchasesUpdated(r: BillingResult, purchases: MutableList<Purchase>?) {
        purchases?.filter { PRODUCT in it.products }?.forEach(::acknowledge)
        // Ask Play for the outcome rather than trusting the callback alone.
        status { s ->
            main.post {
                pendingBuy?.success(s)
                pendingBuy = null
            }
        }
    }

    /** A purchase not acknowledged within three days is refunded by Play. */
    private fun acknowledge(p: Purchase) {
        if (p.purchaseState != Purchase.PurchaseState.PURCHASED || p.isAcknowledged) return
        client.acknowledgePurchase(
            AcknowledgePurchaseParams.newBuilder().setPurchaseToken(p.purchaseToken).build()
        ) { }
    }

    companion object {
        const val CHANNEL = "zigdash/billing"
        const val PRODUCT = "zigdash_pro"

        fun register(activity: Activity, messenger: BinaryMessenger) {
            ProBilling(activity, messenger)
        }
    }
}
