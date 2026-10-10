package com.giladtamam.zigdash

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import android.util.TypedValue
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView

/**
 * Chooses what a home-screen widget shows: opened by the launcher when the
 * widget is added, and by long-press › Reconfigure on Android 12+. A device
 * widget lists the devices on the dashboards, the same list Device Controls
 * offer (shortcut.controls); a scene widget lists the scenes
 * (shortcut.scenes). Both are written by the app.
 */
class WidgetConfigActivity : Activity() {
    private var id = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        id = intent?.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID) ?: AppWidgetManager.INVALID_APPWIDGET_ID
        // Leaving without a choice removes a new widget (the launcher's rule).
        setResult(RESULT_CANCELED, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id))
        if (id == AppWidgetManager.INVALID_APPWIDGET_ID) return finish()

        // The launcher says which widget it's adding: a device or a scene.
        val scene = AppWidgetManager.getInstance(this).getAppWidgetInfo(id)
            ?.provider?.className == SceneWidget::class.java.name

        val pad = dp(20)
        val list = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(pad, pad, pad, dp(12))
            minimumWidth = dp(300)
        }
        list.addView(TextView(this).apply {
            text = if (scene) ShortcutPrefs.word(context, "chooseScene", "Choose a scene")
                   else ShortcutPrefs.word(context, "chooseDevice", "Choose a device")
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            setPadding(0, 0, 0, dp(12))
        })
        // (name, Home, what a tap does)
        val rows: List<Triple<String, String, () -> Unit>> = if (scene) {
            ShortcutPrefs.scenes(this).map { e -> Triple(e.name, e.home) { chooseScene(e) } }
        } else {
            ShortcutPrefs.controls(this).map { e -> Triple(e.name, e.home) { choose(e) } }
        }
        if (rows.isEmpty()) {
            list.addView(TextView(this).apply {
                text = if (scene) ShortcutPrefs.word(context, "openAppFirstScene",
                           "Open ZigDash and create a scene first.")
                       else ShortcutPrefs.word(context, "openAppFirst",
                           "Open ZigDash and put a device on a dashboard first.")
                setPadding(0, dp(8), 0, dp(8))
                setOnClickListener {
                    startActivity(Intent(context, MainActivity::class.java)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    finish()
                }
            })
        }
        val homes = rows.map { it.second }.distinct().size > 1
        for ((name, home, pick) in rows) {
            list.addView(LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(0, dp(10), 0, dp(10))
                isClickable = true
                val ripple = TypedValue()
                context.theme.resolveAttribute(android.R.attr.selectableItemBackground, ripple, true)
                setBackgroundResource(ripple.resourceId)
                addView(TextView(context).apply {
                    text = name
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
                })
                if (homes) addView(TextView(context).apply {
                    text = home
                    alpha = 0.7f
                })
                setOnClickListener { pick() }
            })
        }
        setContentView(ScrollView(this).apply {
            addView(list, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT))
        })
    }

    private fun chooseScene(e: ShortcutPrefs.SceneEntry) {
        ShortcutPrefs.setSceneWidget(this, id, e)
        SceneWidget.render(this, AppWidgetManager.getInstance(this), id)
        ShortcutPrefs.mark(this, "shortcut.added.scene_widget")
        setResult(RESULT_OK, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id))
        finish()
    }

    private fun choose(e: ShortcutPrefs.ControlEntry) {
        ShortcutPrefs.setWidget(this, id, e)
        DeviceWidget.render(this, AppWidgetManager.getInstance(this), id)
        ShortcutPrefs.mark(this, "shortcut.added.widget")
        // Ask the device for its state so the new widget isn't blank.
        // Through the foreground service: this screen closes right away.
        val ask = Intent(this, WidgetActionService::class.java)
            .setAction(WidgetActionService.ACTION_WATCH)
            .putExtra(DeviceWidget.EXTRA_ID, id)
        if (android.os.Build.VERSION.SDK_INT >= 26) startForegroundService(ask) else startService(ask)
        setResult(RESULT_OK, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id))
        finish()
    }

    private fun dp(v: Int) = (v * resources.displayMetrics.density).toInt()
}
