package com.giladtamam.zigdash

import android.app.StatusBarManager
import android.content.ComponentName
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The app. Its `zigdash/app` channel tells Dart when a shortcut opened it
 * (an unassigned Quick Settings tile asks for a device) and asks Android to
 * add a tile (Android 13+).
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    /** Alarm takeover's tone (wall-tablet-2.9.md §6), while one shows. */
    private var alarmTone: android.media.Ringtone? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ProBilling.register(this, flutterEngine.dartExecutor.binaryMessenger)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "zigdash/app")
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "takeAction" -> result.success(takeAction(intent))
                "requestAddTile" -> requestAddTile(call.argument<Int>("slot") ?: 1,
                    call.argument<String>("label") ?: "ZigDash", result)
                "requestPinWidget" -> result.success(PinWidgetReceiver.request(this,
                    call.argument<String>("kind") ?: "device",
                    call.argument<String>("connectionId") ?: "",
                    call.argument<String>("target") ?: "",
                    call.argument<String>("name") ?: ""))
                "generateVapidKeys" -> result.success(generateVapidKeys())
                "timeZoneId" -> result.success(java.util.TimeZone.getDefault().id)
                // Google's test devices (Play's pre-launch report, Firebase
                // Test Lab) set this; they send no usage data (3.1.2).
                "isTestDevice" -> result.success(try {
                    android.provider.Settings.System.getString(
                        contentResolver, "firebase.test.lab") == "true"
                } catch (_: Exception) { false })
                // "Ask your AI" in setup (3.1.5): Android's share sheet, so
                // the write-up reaches whichever AI app the user picks.
                "shareText" -> {
                    val send = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_TEXT, call.argument<String>("text") ?: "")
                    }
                    try {
                        startActivity(Intent.createChooser(send, call.argument<String>("title")))
                        result.success(true)
                    } catch (_: Exception) {
                        result.success(false)
                    }
                }
                // Setup (3.1.8): Home Assistant on the network, by DNS-SD.
                "findServices" -> ServiceFinder(this).find(
                    call.argument<String>("type") ?: "",
                    (call.argument<Int>("timeoutMs") ?: 3000).toLong(),
                ) { result.success(it) }
                // Setup's no-network screen (2.9.4): the Wi-Fi panel over the
                // app on Android 10+, the Wi-Fi settings page before.
                "openWifiSettings" -> {
                    val action = if (android.os.Build.VERSION.SDK_INT >= 29)
                        android.provider.Settings.Panel.ACTION_WIFI
                    else android.provider.Settings.ACTION_WIFI_SETTINGS
                    try {
                        startActivity(android.content.Intent(action))
                        result.success(true)
                    } catch (_: Exception) {
                        try {
                            startActivity(android.content.Intent(
                                android.provider.Settings.ACTION_WIFI_SETTINGS))
                            result.success(true)
                        } catch (_: Exception) {
                            result.success(false)
                        }
                    }
                }
                // Wall display / kiosk (kiosk-2.6.md): dim this window, and
                // Android screen pinning. Brightness -1 = the system's.
                "setBrightness" -> {
                    val value = (call.argument<Double>("value") ?: -1.0).toFloat()
                    window.attributes = window.attributes.apply { screenBrightness = value }
                    result.success(null)
                }
                "lockTask" -> {
                    try {
                        if (call.argument<Boolean>("on") == true) startLockTask() else stopLockTask()
                        result.success(true)
                    } catch (_: Exception) {
                        // Not allowed here (e.g. a managed device): nothing to pin.
                        result.success(false)
                    }
                }
                // Alarm takeover: the phone's own alarm tone, looping, until OK.
                "alarmSound" -> {
                    alarmTone?.stop()
                    alarmTone = null
                    if (call.argument<Boolean>("on") == true) {
                        val uri = android.media.RingtoneManager.getDefaultUri(
                            android.media.RingtoneManager.TYPE_ALARM)
                            ?: android.media.RingtoneManager.getDefaultUri(
                                android.media.RingtoneManager.TYPE_NOTIFICATION)
                        alarmTone = android.media.RingtoneManager.getRingtone(this, uri)?.apply {
                            // The alarm stream: heard on a tablet set to silent.
                            audioAttributes = android.media.AudioAttributes.Builder()
                                .setUsage(android.media.AudioAttributes.USAGE_ALARM)
                                .setContentType(android.media.AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                .build()
                            if (Build.VERSION.SDK_INT >= 28) isLooping = true
                            play()
                        }
                    }
                    result.success(null)
                }
                // Alerts: a background-restricted app gets no pushes (alerts-2.3.md).
                "isBackgroundRestricted" -> result.success(
                    Build.VERSION.SDK_INT >= 28 &&
                        getSystemService(android.app.ActivityManager::class.java).isBackgroundRestricted)
                "refreshTiles" -> {
                    for (c in listOf(ShortcutTile1::class.java, ShortcutTile2::class.java,
                            ShortcutTile3::class.java, ShortcutTile4::class.java)) {
                        try {
                            android.service.quicksettings.TileService.requestListeningState(
                                this, ComponentName(this, c))
                        } catch (_: Exception) {
                            // Not added to Quick Settings: nothing to redraw.
                        }
                    }
                    DeviceWidget.refreshAll(this)
                    SceneWidget.refreshAll(this)
                    GroupWidget.refreshAll(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        channel = ch
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // Local-network permission (alerts-2.3.md §3): Android 17 blocks LAN
        // connections without it, so ask once at start where it exists.
        // Android's own prompt explains what it is for.
        if (Build.VERSION.SDK_INT >= 37) {
            val p = "android.permission.ACCESS_LOCAL_NETWORK"
            if (checkSelfPermission(p) != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                requestPermissions(arrayOf(p), 1701)
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        takeAction(intent)?.let { channel?.invokeMethod("action", it) }
    }

    /** The shortcut request in [intent], once. */
    private fun takeAction(intent: Intent?): Map<String, Any>? {
        val action = intent?.getStringExtra(EXTRA_ACTION) ?: return null
        val slot = intent.getIntExtra(EXTRA_SLOT, 0)
        intent.removeExtra(EXTRA_ACTION)
        return buildMap {
            put("action", action)
            put("slot", slot)
            intent.getStringExtra(EXTRA_HOME)?.let { put("connectionId", it) }
            intent.getStringExtra(EXTRA_IEEE)?.let { put("ieee", it) }
        }
    }

    /**
     * A fresh VAPID key pair for a Home's alerts (alerts-2.3.md): the public
     * key (65 bytes, base64url) that the phone registers with, and the
     * private key as a JWK the hub signs with.
     */
    private fun generateVapidKeys(): Map<String, Any> {
        val gen = java.security.KeyPairGenerator.getInstance("EC")
        gen.initialize(java.security.spec.ECGenParameterSpec("secp256r1"))
        val pair = gen.generateKeyPair()
        val pub = pair.public as java.security.interfaces.ECPublicKey
        val priv = pair.private as java.security.interfaces.ECPrivateKey
        fun fixed(n: java.math.BigInteger): ByteArray {
            val raw = n.toByteArray()
            val out = ByteArray(32)
            val src = if (raw.size > 32) raw.copyOfRange(raw.size - 32, raw.size) else raw
            System.arraycopy(src, 0, out, 32 - src.size, src.size)
            return out
        }
        val b64 = { b: ByteArray -> android.util.Base64.encodeToString(b,
            android.util.Base64.URL_SAFE or android.util.Base64.NO_PADDING or android.util.Base64.NO_WRAP) }
        val x = fixed(pub.w.affineX); val y = fixed(pub.w.affineY)
        return mapOf(
            "publicKey" to b64(byteArrayOf(4) + x + y),
            "privateJwk" to mapOf("kty" to "EC", "crv" to "P-256", "x" to b64(x), "y" to b64(y), "d" to b64(fixed(priv.s))),
        )
    }

    private fun requestAddTile(slot: Int, label: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success("unsupported")
            return
        }
        val service = when (slot) {
            1 -> ShortcutTile1::class.java
            2 -> ShortcutTile2::class.java
            3 -> ShortcutTile3::class.java
            else -> ShortcutTile4::class.java
        }
        val sbm = getSystemService(StatusBarManager::class.java)
        sbm.requestAddTileService(
            ComponentName(this, service), label,
            Icon.createWithResource(this, R.drawable.ic_shortcut_tile), mainExecutor
        ) { code ->
            result.success(when (code) {
                StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_ADDED -> "added"
                StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_ALREADY_ADDED -> "already"
                StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_NOT_ADDED -> "declined"
                else -> "failed"
            })
        }
    }

    companion object {
        const val EXTRA_ACTION = "zigdash.action"
        const val EXTRA_SLOT = "zigdash.slot"
        const val EXTRA_HOME = "zigdash.home"
        const val EXTRA_IEEE = "zigdash.ieee"
    }
}
