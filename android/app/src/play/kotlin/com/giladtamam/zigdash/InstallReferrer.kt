package com.giladtamam.zigdash

import android.app.Activity
import android.os.Handler
import android.os.Looper
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Google Play's install referrer (docs/design/ha-link.md), Play build only:
 * a ZigDash connect link opened before ZigDash was installed carries Home
 * Assistant's address here, once. The foss build has a stub.
 *
 * Channel "zigdash/referrer":
 *  - take -> the referrer string, or null when Play has none or can't say
 */
class InstallReferrer(private val activity: Activity, messenger: BinaryMessenger) {

    private val main = Handler(Looper.getMainLooper())

    init {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "take") take(result) else result.notImplemented()
        }
    }

    private fun take(result: MethodChannel.Result) {
        val client = InstallReferrerClient.newBuilder(activity).build()
        var answered = false
        fun answer(value: String?) {
            if (answered) return
            answered = true
            main.post { result.success(value) }
            try {
                client.endConnection()
            } catch (_: Exception) {
                // Already closed.
            }
        }
        try {
            client.startConnection(object : InstallReferrerStateListener {
                override fun onInstallReferrerSetupFinished(code: Int) {
                    answer(
                        if (code == InstallReferrerClient.InstallReferrerResponse.OK) {
                            try {
                                client.installReferrer.installReferrer
                            } catch (_: Exception) {
                                null
                            }
                        } else {
                            null
                        }
                    )
                }

                override fun onInstallReferrerServiceDisconnected() = answer(null)
            })
        } catch (_: Exception) {
            answer(null)
        }
    }

    companion object {
        private const val CHANNEL = "zigdash/referrer"

        fun register(activity: Activity, messenger: BinaryMessenger) {
            InstallReferrer(activity, messenger)
        }
    }
}
