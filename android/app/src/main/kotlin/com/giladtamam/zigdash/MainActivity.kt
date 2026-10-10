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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "zigdash/app")
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "takeAction" -> result.success(takeAction(intent))
                "requestAddTile" -> requestAddTile(call.argument<Int>("slot") ?: 1,
                    call.argument<String>("label") ?: "ZigDash", result)
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
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        channel = ch
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
        return mapOf("action" to action, "slot" to slot)
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
    }
}
