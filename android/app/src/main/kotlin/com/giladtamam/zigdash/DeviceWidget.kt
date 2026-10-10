package com.giladtamam.zigdash

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.text.format.DateUtils
import android.util.SizeF
import android.widget.RemoteViews

/**
 * The one-device home-screen widget (docs/design/roadmap-post-2.0.md,
 * widgets): icon, name and state line; amber while the device is on. A tap
 * goes through [WidgetActionService] (a short foreground task: Android may
 * block network for an idle app). A shutter shows its position as a bar
 * with ▲ ■ ▼; its name opens the slider pop-up. A sensor shows its reading
 * and opens ZigDash on the device.
 */
class DeviceWidget : AppWidgetProvider() {
    override fun onUpdate(ctx: Context, mgr: AppWidgetManager, ids: IntArray) {
        for (id in ids) render(ctx, mgr, id)
    }

    override fun onAppWidgetOptionsChanged(ctx: Context, mgr: AppWidgetManager, id: Int, options: Bundle) {
        render(ctx, mgr, id)
    }

    override fun onDeleted(ctx: Context, ids: IntArray) {
        for (id in ids) ShortcutPrefs.removeWidget(ctx, id)
    }

    companion object {
        const val EXTRA_ID = "zigdash.widget"

        /** Redraws every device widget (after a state change). */
        fun refreshAll(ctx: Context) {
            val mgr = AppWidgetManager.getInstance(ctx)
            for (id in mgr.getAppWidgetIds(ComponentName(ctx, DeviceWidget::class.java))) {
                render(ctx, mgr, id)
            }
        }

        /** Draws widget [id]; [working] or [problem] replace the state line. */
        fun render(ctx: Context, mgr: AppWidgetManager, id: Int,
                   working: Boolean = false, problem: String? = null) {
            val t = ShortcutPrefs.widget(ctx, id)
            val views = if (Build.VERSION.SDK_INT >= 31) {
                RemoteViews(mapOf(
                    SizeF(110f, 40f) to views(ctx, id, t, strip = true, working, problem),
                    SizeF(110f, 100f) to views(ctx, id, t, strip = false, working, problem),
                ))
            } else {
                val h = mgr.getAppWidgetOptions(id).getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
                views(ctx, id, t, strip = h in 1..99, working, problem)
            }
            mgr.updateAppWidget(id, views)
        }

        private fun views(ctx: Context, id: Int, t: ShortcutPrefs.Tile?, strip: Boolean,
                          working: Boolean, problem: String?): RemoteViews {
            if (t == null) {
                // Not set up (the picker was left): tapping opens it again.
                val v = RemoteViews(ctx.packageName,
                    if (strip) R.layout.widget_device_strip else R.layout.widget_device)
                v.setTextViewText(R.id.w_name, "ZigDash")
                v.setTextViewText(R.id.w_line, ShortcutPrefs.word(ctx, "chooseDevice", "Choose a device"))
                v.setImageViewResource(R.id.w_icon, R.drawable.ic_shortcut_tile)
                v.setOnClickPendingIntent(R.id.w_root, PendingIntent.getActivity(ctx, id,
                    Intent(ctx, WidgetConfigActivity::class.java)
                        .putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
                return v
            }
            val s = ShortcutPrefs.state(ctx, t.connectionId, t.ieee)
            val on = s?.on == true
            val shutter = t.cover && t.position
            val v = RemoteViews(ctx.packageName, when {
                shutter && strip -> R.layout.widget_cover_strip
                shutter -> R.layout.widget_cover
                strip -> R.layout.widget_device_strip
                else -> R.layout.widget_device
            })
            val line = when {
                working -> ShortcutPrefs.word(ctx, "working", "working…")
                problem != null -> problem
                // Beside three buttons only the position fits.
                shutter && strip -> ShortcutPrefs.position(ctx, t.connectionId, t.ieee)
                    ?.let { "$it%" } ?: withAge(s?.line, s?.at) ?: ""
                else -> withAge(s?.line, s?.at) ?: ""
            }
            v.setTextViewText(R.id.w_name, t.name)
            v.setTextViewText(R.id.w_line, line)
            if (!(shutter && strip)) v.setImageViewResource(R.id.w_icon, t.icon)
            // Amber while on; a shutter's frame stays neutral, its bar shows
            // the position.
            val amber = on && !shutter
            v.setInt(R.id.w_root, "setBackgroundResource",
                if (amber) R.drawable.w_row_on else R.drawable.w_frame)
            val ink = ctx.getColor(if (amber) R.color.w_on_amber else R.color.w_ink)
            val ink2 = ctx.getColor(if (amber) R.color.w_on_amber2 else R.color.w_ink2)
            v.setTextColor(R.id.w_name, ink)
            v.setTextColor(R.id.w_line, if (problem != null) ctx.getColor(R.color.w_problem) else ink2)
            if (!(shutter && strip)) v.setInt(R.id.w_icon, "setColorFilter", ink)
            if (shutter) {
                if (!strip) {
                    v.setProgressBar(R.id.w_bar, 100,
                        ShortcutPrefs.level(ctx, t.connectionId, t.ieee) ?: 0, false)
                }
                for ((view, action) in listOf(R.id.w_up to "OPEN", R.id.w_stop to "STOP", R.id.w_down to "CLOSE")) {
                    v.setInt(view, "setColorFilter", ink)
                    v.setOnClickPendingIntent(view, action(ctx, id, action))
                }
                v.setOnClickPendingIntent(R.id.w_head, PendingIntent.getActivity(ctx, id,
                    CoverControlActivity.intent(ctx, t),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
            } else if (isSensor(t)) {
                v.setOnClickPendingIntent(R.id.w_root, PendingIntent.getActivity(ctx, id,
                    Intent(ctx, MainActivity::class.java)
                        .putExtra(MainActivity.EXTRA_ACTION, "openDevice")
                        .putExtra(MainActivity.EXTRA_HOME, t.connectionId)
                        .putExtra(MainActivity.EXTRA_IEEE, t.ieee)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
            } else {
                v.setOnClickPendingIntent(R.id.w_root, action(ctx, id, "TOGGLE"))
            }
            return v
        }

        private fun isSensor(t: ShortcutPrefs.Tile) =
            t.deviceClass in setOf("climate", "contact", "motion", "leakSmoke")

        /** A tap's PendingIntent: [action] for widget [id], run as a short
         *  foreground task. Request codes keep each widget's buttons apart. */
        private fun action(ctx: Context, id: Int, action: String): PendingIntent {
            val i = Intent(ctx, WidgetActionService::class.java)
                .setAction(action)
                .putExtra(EXTRA_ID, id)
            val code = id * 8 + listOf("TOGGLE", "OPEN", "STOP", "CLOSE").indexOf(action)
            return PendingIntent.getForegroundService(ctx, code, i,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        }

        /** The last-known line, with its age once it's over a minute old. */
        internal fun withAge(line: String?, at: Long?, short: Boolean = false): String? {
            if (line == null || at == null) return line
            val now = System.currentTimeMillis()
            if (now - at < DateUtils.MINUTE_IN_MILLIS) return line
            // [short]: "5 min. ago", for a group widget's narrow rows.
            val age = DateUtils.getRelativeTimeSpanString(at, now, DateUtils.MINUTE_IN_MILLIS,
                if (short) DateUtils.FORMAT_ABBREV_RELATIVE else 0)
            return "$line · $age"
        }
    }
}
