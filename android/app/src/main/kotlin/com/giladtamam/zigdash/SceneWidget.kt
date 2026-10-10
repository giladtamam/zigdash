package com.giladtamam.zigdash

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.widget.RemoteViews

/**
 * The scene button (docs/design/roadmap-post-2.0.md, widgets): a
 * one-device-sized widget that runs a scene. Its line shows the last run,
 * "Sent" then "Confirmed" once every device answered, with its age. A tap
 * goes through [WidgetActionService], like a device widget's.
 */
class SceneWidget : AppWidgetProvider() {
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
        /** Redraws every scene widget (after a run, or a rename in the app). */
        fun refreshAll(ctx: Context) {
            val mgr = AppWidgetManager.getInstance(ctx)
            for (id in mgr.getAppWidgetIds(ComponentName(ctx, SceneWidget::class.java))) {
                render(ctx, mgr, id)
            }
        }

        /** Draws widget [id]; [working] or [problem] replace the line. */
        fun render(ctx: Context, mgr: AppWidgetManager, id: Int,
                   working: Boolean = false, problem: String? = null) {
            val views = if (Build.VERSION.SDK_INT >= 31) {
                RemoteViews(mapOf(
                    SizeF(110f, 40f) to views(ctx, id, strip = true, working, problem),
                    SizeF(110f, 100f) to views(ctx, id, strip = false, working, problem),
                ))
            } else {
                val h = mgr.getAppWidgetOptions(id).getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
                views(ctx, id, strip = h in 1..99, working, problem)
            }
            mgr.updateAppWidget(id, views)
        }

        /** How a widget for scene [e] looks, for the launcher's "Add?" prompt. */
        fun preview(ctx: Context, e: ShortcutPrefs.SceneEntry): RemoteViews =
            views(ctx, 0, strip = false, working = false, problem = null, entry = e)

        private fun views(ctx: Context, id: Int, strip: Boolean,
                          working: Boolean, problem: String?,
                          entry: ShortcutPrefs.SceneEntry? = null): RemoteViews {
            val v = RemoteViews(ctx.packageName,
                if (strip) R.layout.widget_device_strip else R.layout.widget_device)
            v.setImageViewResource(R.id.w_icon, R.drawable.w_ic_scene)
            v.setInt(R.id.w_root, "setBackgroundResource", R.drawable.w_frame)
            val ink = ctx.getColor(R.color.w_ink)
            v.setTextColor(R.id.w_name, ink)
            v.setInt(R.id.w_icon, "setColorFilter", ink)
            v.setTextColor(R.id.w_line, ctx.getColor(
                if (problem != null) R.color.w_problem else R.color.w_ink2))
            val e = entry ?: ShortcutPrefs.sceneWidget(ctx, id)
            if (e == null) {
                // Not set up (the picker was left): tapping opens it again.
                v.setTextViewText(R.id.w_name, "ZigDash")
                v.setTextViewText(R.id.w_line,
                    ShortcutPrefs.word(ctx, "chooseScene", "Choose a scene"))
                v.setOnClickPendingIntent(R.id.w_root, PendingIntent.getActivity(ctx, id,
                    Intent(ctx, WidgetConfigActivity::class.java)
                        .putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
                return v
            }
            val s = ShortcutPrefs.state(ctx, e.connectionId, e.sceneId)
            v.setTextViewText(R.id.w_name, e.name)
            v.setTextViewText(R.id.w_line, when {
                working -> ShortcutPrefs.word(ctx, "working", "working…")
                problem != null -> problem
                else -> DeviceWidget.withAge(s?.line, s?.at) ?: ""
            })
            v.setOnClickPendingIntent(R.id.w_root, PendingIntent.getForegroundService(
                ctx, id * 8 + 4,
                Intent(ctx, WidgetActionService::class.java)
                    .setAction(WidgetActionService.ACTION_SCENE)
                    .putExtra(DeviceWidget.EXTRA_ID, id),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
            return v
        }
    }
}
