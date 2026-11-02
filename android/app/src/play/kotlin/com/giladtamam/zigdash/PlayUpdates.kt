package com.giladtamam.zigdash

import android.app.Activity
import android.os.Handler
import android.os.Looper
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Play's in-app updates (3.2.3), in the Play build only: the foss build has
 * a stub and no Play library. Play says whether a newer version exists,
 * downloads it while ZigDash stays open, and installs it on "complete".
 *
 * Channel "zigdash/update":
 *  - check    -> {available, versionCode, downloaded} or null when Play can't say
 *  - start    -> true when Play's flexible download started
 *  - complete -> installs a downloaded update (the app restarts)
 * Native to Dart: "downloaded", once the download finished.
 */
class PlayUpdates(private val activity: Activity, messenger: BinaryMessenger) {

    private val main = Handler(Looper.getMainLooper())
    private val manager = AppUpdateManagerFactory.create(activity)
    private val channel = MethodChannel(messenger, CHANNEL)

    private val listener = InstallStateUpdatedListener { state ->
        if (state.installStatus() == InstallStatus.DOWNLOADED) {
            main.post { channel.invokeMethod("downloaded", null) }
        }
    }

    init {
        manager.registerListener(listener)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "check" -> check(result)
                "start" -> start(result)
                "complete" -> {
                    manager.completeUpdate()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun check(result: MethodChannel.Result) {
        manager.appUpdateInfo
            .addOnSuccessListener { info ->
                val available = info.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE &&
                    info.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE)
                main.post {
                    result.success(
                        mapOf(
                            "available" to available,
                            "versionCode" to info.availableVersionCode(),
                            "downloaded" to (info.installStatus() == InstallStatus.DOWNLOADED),
                        )
                    )
                }
            }
            .addOnFailureListener { main.post { result.success(null) } }
    }

    private fun start(result: MethodChannel.Result) {
        manager.appUpdateInfo
            .addOnSuccessListener { info ->
                val started = info.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE &&
                    info.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE) &&
                    manager.startUpdateFlowForResult(
                        info,
                        activity,
                        AppUpdateOptions.defaultOptions(AppUpdateType.FLEXIBLE),
                        REQUEST,
                    )
                main.post { result.success(started) }
            }
            .addOnFailureListener { main.post { result.success(false) } }
    }

    companion object {
        const val CHANNEL = "zigdash/update"
        private const val REQUEST = 7301

        fun register(activity: Activity, messenger: BinaryMessenger) {
            PlayUpdates(activity, messenger)
        }
    }
}
