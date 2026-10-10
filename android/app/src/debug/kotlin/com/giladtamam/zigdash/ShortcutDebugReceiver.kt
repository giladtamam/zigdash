package com.giladtamam.zigdash

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Debug builds only: drives the shortcut engine from adb.
 *   adb shell am broadcast -n com.giladtamam.zigdash/.ShortcutDebugReceiver \
 *     --es cmd toggle --es home <connectionId> --es ieee <0x...>
 *   ... --es cmd scene --es home <connectionId> --es scene <sceneId>
 */
class ShortcutDebugReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        val tap = System.currentTimeMillis()
        val pending = goAsync()
        val home = intent.getStringExtra("home") ?: return pending.finish()
        val done = { json: String ->
            Log.i("ZigDashShortcuts", "{\"ms\":${System.currentTimeMillis() - tap},\"result\":$json}")
            pending.finish()
        }
        when (intent.getStringExtra("cmd")) {
            "scene" -> ShortcutEngine.scene(ctx, home, intent.getStringExtra("scene") ?: "", done)
            else -> ShortcutEngine.toggle(ctx, home, intent.getStringExtra("ieee") ?: "", done)
        }
    }
}
