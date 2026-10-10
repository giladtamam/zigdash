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
 * Chooses the device a home-screen widget shows: opened by the launcher
 * when the widget is added, and by long-press › Reconfigure on Android 12+.
 * Lists the devices on the dashboards, the same list Device Controls offer
 * (written by the app, shortcut.controls).
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

        val pad = dp(20)
        val list = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(pad, pad, pad, dp(12))
            minimumWidth = dp(300)
        }
        list.addView(TextView(this).apply {
            text = ShortcutPrefs.word(context, "chooseDevice", "Choose a device")
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            setPadding(0, 0, 0, dp(12))
        })
        val devices = ShortcutPrefs.controls(this)
        if (devices.isEmpty()) {
            list.addView(TextView(this).apply {
                text = ShortcutPrefs.word(context, "openAppFirst",
                    "Open ZigDash and put a device on a dashboard first.")
                setPadding(0, dp(8), 0, dp(8))
                setOnClickListener {
                    startActivity(Intent(context, MainActivity::class.java)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    finish()
                }
            })
        }
        val homes = devices.map { it.home }.distinct().size > 1
        for (e in devices) {
            list.addView(LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(0, dp(10), 0, dp(10))
                isClickable = true
                val ripple = TypedValue()
                context.theme.resolveAttribute(android.R.attr.selectableItemBackground, ripple, true)
                setBackgroundResource(ripple.resourceId)
                addView(TextView(context).apply {
                    text = e.name
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
                })
                if (homes) addView(TextView(context).apply {
                    text = e.home
                    alpha = 0.7f
                })
                setOnClickListener { choose(e) }
            })
        }
        setContentView(ScrollView(this).apply {
            addView(list, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT))
        })
    }

    private fun choose(e: ShortcutPrefs.ControlEntry) {
        ShortcutPrefs.setWidget(this, id, e)
        DeviceWidget.render(this, AppWidgetManager.getInstance(this), id)
        ShortcutPrefs.mark(this, "shortcut.added.widget")
        // Ask the device for its state so the new widget isn't blank.
        ShortcutEngine.watch(this, e.connectionId, listOf(e.ieee)) {}
        setResult(RESULT_OK, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id))
        finish()
    }

    private fun dp(v: Int) = (v * resources.displayMetrics.density).toInt()
}
