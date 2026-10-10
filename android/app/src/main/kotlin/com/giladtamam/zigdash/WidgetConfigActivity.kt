package com.giladtamam.zigdash

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import android.util.TypedValue
import android.view.ViewGroup
import android.widget.Button
import android.widget.CheckBox
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView

/**
 * Chooses what a home-screen widget shows: opened by the launcher when the
 * widget is added, and by long-press › Reconfigure on Android 12+. A device
 * widget lists the devices on the dashboards, the same list Device Controls
 * offer (shortcut.controls); a scene widget lists the scenes
 * (shortcut.scenes); a group widget the dashboard sections
 * (shortcut.groups). All are written by the app.
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
        val provider = AppWidgetManager.getInstance(this).getAppWidgetInfo(id)?.provider?.className
        val scene = provider == SceneWidget::class.java.name
        val group = provider == GroupWidget::class.java.name

        val pad = dp(20)
        val list = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(pad, pad, pad, dp(12))
            minimumWidth = dp(300)
        }
        list.addView(TextView(this).apply {
            text = when {
                scene -> ShortcutPrefs.word(context, "chooseScene", "Choose a scene")
                group -> ShortcutPrefs.word(context, "chooseGroup", "Choose a group")
                else -> ShortcutPrefs.word(context, "chooseDevice", "Choose a device")
            }
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            setPadding(0, 0, 0, dp(12))
        })
        // (name, where it is, what a tap does)
        val rows: List<Triple<String, String, () -> Unit>> = when {
            scene -> ShortcutPrefs.scenes(this).map { e -> Triple(e.name, e.home) { chooseScene(e) } }
            group -> {
                // A section is named within its dashboard (and Home, if several).
                val all = ShortcutPrefs.groups(this)
                val homes = all.map { it.home }.distinct().size > 1
                all.map { g ->
                    Triple(g.name, if (homes) "${g.home} · ${g.dashboard}" else g.dashboard) {
                        chooseGroup(g)
                    }
                }
            }
            else -> ShortcutPrefs.controls(this).map { e -> Triple(e.name, e.home) { choose(e) } }
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
        val homes = group || rows.map { it.second }.distinct().size > 1
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
                    startAligned()
                })
                if (homes) addView(TextView(context).apply {
                    text = home
                    alpha = 0.7f
                })
                setOnClickListener { pick() }
            })
        }
        // A group can also be put together by hand.
        if (group && ShortcutPrefs.controls(this).isNotEmpty()) {
            list.addView(TextView(this).apply {
                text = ShortcutPrefs.word(context, "pickDevices", "Pick devices…")
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
                setPadding(0, dp(14), 0, dp(10))
                setTypeface(typeface, android.graphics.Typeface.BOLD)
                setOnClickListener { pickByHand() }
            })
        }
        show(list)
    }

    private fun show(content: LinearLayout) = setContentView(ScrollView(this).apply {
        addView(content, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT))
    })

    /**
     * A hand-picked group: a name, up to five devices and three scenes, all
     * from one Home (the first ticked decides it).
     */
    private fun pickByHand() {
        val pad = dp(20)
        val form = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(pad, pad, pad, dp(12))
            minimumWidth = dp(300)
        }
        val name = EditText(this).apply {
            hint = ShortcutPrefs.word(context, "groupName", "Group name")
            setSingleLine()
        }
        form.addView(name)
        form.addView(TextView(this).apply {
            text = ShortcutPrefs.word(context, "groupLimit", "Up to 5 devices and 3 scenes")
            alpha = 0.7f
            setPadding(0, dp(8), 0, dp(8))
        })
        val devices = ShortcutPrefs.controls(this)
        val scenes = ShortcutPrefs.scenes(this)
        val homes = (devices.map { it.home } + scenes.map { it.home }).distinct().size > 1
        // (box, its Home's connection, IEEE or null, scene id or null)
        data class Pick(val box: CheckBox, val conn: String, val ieee: String?, val scene: String?)
        val picks = mutableListOf<Pick>()
        val save = Button(this).apply {
            text = ShortcutPrefs.word(context, "save", "Save")
            isEnabled = false
        }
        fun refresh() {
            val chosen = picks.filter { it.box.isChecked }
            val home = chosen.firstOrNull()?.conn
            val fullDevices = chosen.count { it.ieee != null } >= 5
            val fullScenes = chosen.count { it.scene != null } >= 3
            for (p in picks) {
                p.box.isEnabled = p.box.isChecked || ((home == null || p.conn == home) &&
                    !(p.ieee != null && fullDevices) && !(p.scene != null && fullScenes))
            }
            save.isEnabled = chosen.isNotEmpty()
        }
        fun box(label: String, home: String, conn: String, ieee: String?, scene: String?) {
            val b = CheckBox(this).apply {
                text = if (homes) "$label · $home" else label
                startAligned()
                setOnCheckedChangeListener { _, _ -> refresh() }
            }
            picks.add(Pick(b, conn, ieee, scene))
            form.addView(b)
        }
        for (e in devices) box(e.name, e.home, e.connectionId, e.ieee, null)
        if (scenes.isNotEmpty()) {
            form.addView(TextView(this).apply {
                text = ShortcutPrefs.word(context, "scenes", "Scenes")
                alpha = 0.7f
                setPadding(0, dp(12), 0, dp(4))
            })
        }
        for (e in scenes) box(e.name, e.home, e.connectionId, null, e.sceneId)
        save.setOnClickListener {
            val chosen = picks.filter { it.box.isChecked }
            val first = chosen.firstOrNull() ?: return@setOnClickListener
            val title = name.text.toString().trim().ifEmpty {
                devices.firstOrNull { it.ieee == chosen.firstOrNull { c -> c.ieee != null }?.ieee }?.name
                    ?: "ZigDash"
            }
            chooseGroup(ShortcutPrefs.GroupEntry(first.conn, "", "", title,
                chosen.mapNotNull { it.ieee }, chosen.mapNotNull { it.scene }))
        }
        form.addView(save, LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
            topMargin = dp(12)
        })
        show(form)
    }

    private fun chooseGroup(g: ShortcutPrefs.GroupEntry) {
        ShortcutPrefs.setGroupWidget(this, id, g)
        GroupWidget.render(this, AppWidgetManager.getInstance(this), id)
        ShortcutPrefs.mark(this, "shortcut.added.group_widget")
        askState()
        setResult(RESULT_OK, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id))
        finish()
    }

    /** Asks the new widget's devices for their state so it isn't blank:
     *  through the foreground service, as this screen closes right away. */
    private fun askState() {
        val ask = Intent(this, WidgetActionService::class.java)
            .setAction(WidgetActionService.ACTION_WATCH)
            .putExtra(DeviceWidget.EXTRA_ID, id)
        if (android.os.Build.VERSION.SDK_INT >= 26) startForegroundService(ask) else startService(ask)
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
        askState()
        setResult(RESULT_OK, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id))
        finish()
    }

    private fun dp(v: Int) = (v * resources.displayMetrics.density).toInt()

    /** Every name starts on the same side, whatever its script. */
    private fun TextView.startAligned() {
        // Left or right outright: "start" follows each name's own script.
        val rtl = resources.configuration.layoutDirection == android.view.View.LAYOUT_DIRECTION_RTL
        textDirection = android.view.View.TEXT_DIRECTION_LOCALE
        textAlignment = android.view.View.TEXT_ALIGNMENT_GRAVITY
        gravity = android.view.Gravity.CENTER_VERTICAL or
            (if (rtl) android.view.Gravity.RIGHT else android.view.Gravity.LEFT)
    }
}
