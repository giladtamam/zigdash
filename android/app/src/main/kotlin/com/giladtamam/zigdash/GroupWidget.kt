package com.giladtamam.zigdash

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews

/**
 * The group widget (docs/design/roadmap-post-2.0.md, widgets): a title, up
 * to five devices as rows and up to three scene buttons. A light or plug
 * row toggles, a shutter row opens the slider pop-up, a sensor row opens
 * ZigDash on the device; taps go through [WidgetActionService]. Names come
 * from what the app offers now (shortcut.controls, shortcut.scenes), so
 * renames reach the widget; a device no longer on a dashboard is left out.
 */
class GroupWidget : AppWidgetProvider() {
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
        const val EXTRA_IEEE = "zigdash.ieee"
        const val EXTRA_SCENE = "zigdash.scene"

        private val ROWS = listOf(
            Row(R.id.w_r1, R.id.w_r1_icon, R.id.w_r1_name, R.id.w_r1_line),
            Row(R.id.w_r2, R.id.w_r2_icon, R.id.w_r2_name, R.id.w_r2_line),
            Row(R.id.w_r3, R.id.w_r3_icon, R.id.w_r3_name, R.id.w_r3_line),
            Row(R.id.w_r4, R.id.w_r4_icon, R.id.w_r4_name, R.id.w_r4_line),
            Row(R.id.w_r5, R.id.w_r5_icon, R.id.w_r5_name, R.id.w_r5_line),
        )
        private val SCENES = listOf(R.id.w_s1, R.id.w_s2, R.id.w_s3)

        private data class Row(val root: Int, val icon: Int, val name: Int, val line: Int)

        /** Redraws every group widget (after a state change or a rename). */
        fun refreshAll(ctx: Context) {
            val mgr = AppWidgetManager.getInstance(ctx)
            for (id in mgr.getAppWidgetIds(ComponentName(ctx, GroupWidget::class.java))) {
                render(ctx, mgr, id)
            }
        }

        /**
         * Draws widget [id]. [about] is the device IEEE or scene id just
         * tapped: [working] shows "working…" on that row or button, and
         * [problem] replaces its line afterwards.
         */
        fun render(ctx: Context, mgr: AppWidgetManager, id: Int, about: String? = null,
                   working: Boolean = false, problem: String? = null) {
            val busy = about.takeIf { working }
            val trouble = problem?.let { about to it }
            val views = if (Build.VERSION.SDK_INT >= 31) {
                // How many rows fit each height: title, rows of 42dp, the
                // scene buttons; the launcher picks the largest that fits.
                RemoteViews(listOf(110f, 150f, 190f, 230f, 270f, 310f).associate { h ->
                    SizeF(180f, h) to views(ctx, id, h, busy, trouble)
                })
            } else {
                val h = mgr.getAppWidgetOptions(id)
                    .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT).takeIf { it > 0 } ?: 190
                views(ctx, id, h.toFloat(), busy, trouble)
            }
            mgr.updateAppWidget(id, views)
        }

        private fun views(ctx: Context, id: Int, height: Float,
                          busy: String?, trouble: Pair<String?, String>?): RemoteViews {
            val v = RemoteViews(ctx.packageName, R.layout.widget_group)
            val g = ShortcutPrefs.groupWidget(ctx, id)
            if (g == null) {
                // Not set up (the picker was left): tapping opens it again.
                v.setTextViewText(R.id.w_title,
                    ShortcutPrefs.word(ctx, "chooseGroup", "Choose a group"))
                for (r in ROWS) v.setViewVisibility(r.root, View.GONE)
                v.setViewVisibility(R.id.w_scenes, View.GONE)
                v.setOnClickPendingIntent(R.id.w_root, PendingIntent.getActivity(ctx, id,
                    Intent(ctx, WidgetConfigActivity::class.java)
                        .putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
                return v
            }
            v.setTextViewText(R.id.w_title, g.name)
            val devices = g.ieees.mapNotNull { ShortcutPrefs.control(ctx, g.connectionId, it) }
            val scenes = g.scenes.mapNotNull { s ->
                ShortcutPrefs.sceneName(ctx, g.connectionId, s)?.let { s to it }
            }
            val fit = ((height - 44f - (if (scenes.isEmpty()) 0f else 40f)) / 42f).toInt()
                .coerceIn(1, ROWS.size)
            for ((i, r) in ROWS.withIndex()) {
                val e = devices.getOrNull(i)
                if (e == null || i >= fit) {
                    v.setViewVisibility(r.root, View.GONE)
                    continue
                }
                v.setViewVisibility(r.root, View.VISIBLE)
                drawRow(ctx, v, r, id, g, e, busy, trouble)
            }
            v.setViewVisibility(R.id.w_scenes, if (scenes.isEmpty()) View.GONE else View.VISIBLE)
            for ((i, sv) in SCENES.withIndex()) {
                val s = scenes.getOrNull(i)
                if (s == null) {
                    v.setViewVisibility(sv, View.GONE)
                    continue
                }
                v.setViewVisibility(sv, View.VISIBLE)
                val mine = trouble?.first == s.first
                v.setTextViewText(sv, when {
                    busy == s.first -> ShortcutPrefs.word(ctx, "working", "working…")
                    mine -> trouble!!.second
                    else -> s.second
                })
                v.setTextColor(sv, ctx.getColor(if (mine) R.color.w_problem else R.color.w_ink))
                v.setOnClickPendingIntent(sv, service(ctx, id, 5 + i,
                    WidgetActionService.ACTION_SCENE) { it.putExtra(EXTRA_SCENE, s.first) })
            }
            return v
        }

        private fun drawRow(ctx: Context, v: RemoteViews, r: Row, id: Int,
                            g: ShortcutPrefs.GroupEntry, e: ShortcutPrefs.ControlEntry,
                            busy: String?, trouble: Pair<String?, String>?) {
            val t = ShortcutPrefs.Tile(e.connectionId, e.ieee, e.name,
                cover = e.kind == "cover", position = e.position, deviceClass = e.cls)
            val s = ShortcutPrefs.state(ctx, g.connectionId, e.ieee)
            val mine = trouble?.first == e.ieee
            val amber = s?.on == true && !t.cover && e.kind != "sensor"
            v.setInt(r.root, "setBackgroundResource",
                if (amber) R.drawable.w_row_on else R.drawable.w_row_off)
            val ink = ctx.getColor(if (amber) R.color.w_on_amber else R.color.w_ink)
            v.setImageViewResource(r.icon, t.icon)
            v.setInt(r.icon, "setColorFilter", ink)
            v.setTextViewText(r.name, e.name)
            v.setTextColor(r.name, ink)
            v.setTextViewText(r.line, when {
                busy == e.ieee -> ShortcutPrefs.word(ctx, "working", "working…")
                mine -> trouble!!.second
                else -> DeviceWidget.withAge(s?.line, s?.at) ?: ""
            })
            v.setTextColor(r.line, ctx.getColor(when {
                mine -> R.color.w_problem
                amber -> R.color.w_on_amber2
                else -> R.color.w_ink2
            }))
            val slot = ROWS.indexOf(r)
            v.setOnClickPendingIntent(r.root, when (e.kind) {
                // A shutter has a position: its pop-up, as from a tile.
                "cover" -> PendingIntent.getActivity(ctx, id * 16 + slot,
                    CoverControlActivity.intent(ctx, t).setData(uri(id, slot)),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
                "sensor" -> PendingIntent.getActivity(ctx, id * 16 + slot,
                    Intent(ctx, MainActivity::class.java)
                        .setData(uri(id, slot))
                        .putExtra(MainActivity.EXTRA_ACTION, "openDevice")
                        .putExtra(MainActivity.EXTRA_HOME, e.connectionId)
                        .putExtra(MainActivity.EXTRA_IEEE, e.ieee)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
                else -> service(ctx, id, slot, "TOGGLE") { it.putExtra(EXTRA_IEEE, e.ieee) }
            })
        }

        // Each slot's intent carries its own data URI: PendingIntents that
        // differ only in extras would overwrite one another across widgets.
        private fun uri(id: Int, slot: Int) = Uri.parse("zigdash://widget/$id/$slot")

        private fun service(ctx: Context, id: Int, slot: Int, action: String,
                            extras: (Intent) -> Unit): PendingIntent {
            val i = Intent(ctx, WidgetActionService::class.java)
                .setAction(action)
                .setData(uri(id, slot))
                .putExtra(DeviceWidget.EXTRA_ID, id)
            extras(i)
            return PendingIntent.getForegroundService(ctx, id * 16 + slot, i,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        }
    }
}
