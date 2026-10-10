package com.giladtamam.zigdash

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * "Add to home screen" from inside ZigDash (docs/design/roadmap-post-2.0.md,
 * adding shortcuts): [request] asks the launcher to pin a device, scene or
 * group widget; once the user confirms, Android sends the new widget's id here and
 * the widget is set up as the picker would (the picker isn't shown for a
 * pinned widget).
 */
class PinWidgetReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        val id = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID)
        if (id == AppWidgetManager.INVALID_APPWIDGET_ID) return
        val conn = intent.getStringExtra(EXTRA_HOME) ?: return
        val mgr = AppWidgetManager.getInstance(ctx)
        when (intent.getStringExtra(EXTRA_KIND)) {
            "group" -> {
                val groupId = intent.getStringExtra(EXTRA_TARGET) ?: return
                val g = ShortcutPrefs.groups(ctx)
                    .firstOrNull { it.connectionId == conn && it.id == groupId } ?: return
                ShortcutPrefs.setGroupWidget(ctx, id, g)
                GroupWidget.render(ctx, mgr, id)
                ShortcutPrefs.mark(ctx, "shortcut.added.group_widget")
                askState(ctx, id)
            }
            "scene" -> {
                val sceneId = intent.getStringExtra(EXTRA_TARGET) ?: return
                val e = ShortcutPrefs.scenes(ctx)
                    .firstOrNull { it.connectionId == conn && it.sceneId == sceneId }
                    ?: ShortcutPrefs.SceneEntry(conn, "", sceneId,
                        intent.getStringExtra(EXTRA_NAME) ?: "")
                ShortcutPrefs.setSceneWidget(ctx, id, e)
                SceneWidget.render(ctx, mgr, id)
                ShortcutPrefs.mark(ctx, "shortcut.added.scene_widget")
            }
            else -> {
                val ieee = intent.getStringExtra(EXTRA_TARGET) ?: return
                val e = ShortcutPrefs.control(ctx, conn, ieee) ?: return
                ShortcutPrefs.setWidget(ctx, id, e)
                DeviceWidget.render(ctx, mgr, id)
                ShortcutPrefs.mark(ctx, "shortcut.added.widget")
                askState(ctx, id)
            }
        }
    }

    /** Asks widget [id]'s devices where they are, through the foreground service. */
    private fun askState(ctx: Context, id: Int) {
        try {
            val ask = Intent(ctx, WidgetActionService::class.java)
                .setAction(WidgetActionService.ACTION_WATCH)
                .putExtra(DeviceWidget.EXTRA_ID, id)
            if (Build.VERSION.SDK_INT >= 26) ctx.startForegroundService(ask)
            else ctx.startService(ask)
        } catch (_: Exception) {
            // Not allowed from the background: the widget shows the
            // last-known state until the app or a tap refreshes it.
        }
    }

    companion object {
        private const val EXTRA_KIND = "zigdash.kind"
        private const val EXTRA_HOME = "zigdash.home"
        private const val EXTRA_TARGET = "zigdash.target"
        private const val EXTRA_NAME = "zigdash.name"

        /**
         * Asks the launcher to pin a [kind] ("device", "scene" or "group")
         * widget for [target] (an IEEE, a scene id, or a group id from
         * shortcut.groups) of Home [connectionId]. "requested"
         * when the launcher's prompt opened, "unsupported" when the launcher
         * can't pin widgets.
         */
        fun request(ctx: Context, kind: String, connectionId: String, target: String,
                    name: String): String {
            if (Build.VERSION.SDK_INT < 26) return "unsupported"
            val mgr = ctx.getSystemService(AppWidgetManager::class.java)
            if (mgr == null || !mgr.isRequestPinAppWidgetSupported) return "unsupported"
            val provider = ComponentName(ctx, when (kind) {
                "scene" -> SceneWidget::class.java
                "group" -> GroupWidget::class.java
                else -> DeviceWidget::class.java
            })
            val done = Intent(ctx, PinWidgetReceiver::class.java)
                .putExtra(EXTRA_KIND, kind)
                .putExtra(EXTRA_HOME, connectionId)
                .putExtra(EXTRA_TARGET, target)
                .putExtra(EXTRA_NAME, name)
            // Mutable: Android adds the new widget's id to it.
            val callback = PendingIntent.getBroadcast(ctx, (kind + target).hashCode(), done,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    (if (Build.VERSION.SDK_INT >= 31) PendingIntent.FLAG_MUTABLE else 0))
            // The prompt shows the widget as it will look, not the sample.
            val preview = if (kind == "group") {
                ShortcutPrefs.groups(ctx)
                    .firstOrNull { it.connectionId == connectionId && it.id == target }
                    ?.let { GroupWidget.preview(ctx, it) }
            } else if (kind == "scene") {
                ShortcutPrefs.scenes(ctx)
                    .firstOrNull { it.connectionId == connectionId && it.sceneId == target }
                    ?.let { SceneWidget.preview(ctx, it) }
            } else {
                ShortcutPrefs.control(ctx, connectionId, target)?.let { e ->
                    DeviceWidget.preview(ctx, ShortcutPrefs.Tile(e.connectionId, e.ieee, e.name,
                        cover = e.kind == "cover", position = e.position, deviceClass = e.cls))
                }
            }
            val extras = preview?.let {
                android.os.Bundle().apply { putParcelable(AppWidgetManager.EXTRA_APPWIDGET_PREVIEW, it) }
            }
            return if (mgr.requestPinAppWidget(provider, extras, callback)) "requested" else "unsupported"
        }
    }
}
