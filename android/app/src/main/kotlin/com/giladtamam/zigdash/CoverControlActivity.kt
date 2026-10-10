package com.giladtamam.zigdash

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.SeekBar
import android.widget.TextView

/**
 * The shutter pop-up (2.1 §3–4, changed 2026-10-10: shutters get a position,
 * not on/off): name, live state line, a position slider and Open / Stop /
 * Close. Opened by a shutter's Quick Settings tile and home-screen widget.
 * Commands go through [ShortcutEngine]; the line follows the shutter as the
 * engine writes its state.
 */
class CoverControlActivity : Activity() {
    private lateinit var connectionId: String
    private lateinit var ieee: String
    private lateinit var line: TextView
    private var slider: SeekBar? = null
    private var dragging = false
    private var lastSent = -1
    private var lastSentAt = 0L

    private val changes = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
        if (key == "flutter.shortcut.state.$connectionId.$ieee") runOnUiThread { render() }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        connectionId = intent.getStringExtra(EXTRA_HOME) ?: return finish()
        ieee = intent.getStringExtra(EXTRA_IEEE) ?: return finish()
        val name = intent.getStringExtra(EXTRA_NAME) ?: ""
        val hasPosition = intent.getBooleanExtra(EXTRA_POSITION, true)
        ShortcutEngine.warm(this)

        val pad = dp(24)
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(pad, pad, pad, dp(16))
            minimumWidth = dp(300)
        }
        root.addView(TextView(this).apply {
            text = name
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
        })
        line = TextView(this).apply {
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            alpha = 0.75f
            setPadding(0, dp(4), 0, dp(16))
        }
        root.addView(line)
        if (hasPosition) {
            root.addView(TextView(this).apply {
                text = ShortcutPrefs.word(context, "position", "Position")
            })
            slider = SeekBar(this).apply {
                max = 100
                setPadding(dp(8), dp(12), dp(8), dp(12))
                setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                    override fun onProgressChanged(b: SeekBar, p: Int, fromUser: Boolean) {}
                    override fun onStartTrackingTouch(b: SeekBar) { dragging = true }
                    override fun onStopTrackingTouch(b: SeekBar) {
                        dragging = false
                        // Some phones report one release twice; send it once.
                        val now = System.currentTimeMillis()
                        if (b.progress == lastSent && now - lastSentAt < 1000) return
                        lastSent = b.progress
                        lastSentAt = now
                        send { done -> ShortcutEngine.position(context, connectionId, ieee, b.progress, done) }
                    }
                })
            }
            root.addView(slider)
        }
        val buttons = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            setPadding(0, dp(12), 0, 0)
        }
        for ((action, key, fallback) in listOf(
            Triple("OPEN", "open", "Open"), Triple("STOP", "stop", "Stop"), Triple("CLOSE", "close", "Close"))) {
            buttons.addView(Button(this).apply {
                text = ShortcutPrefs.word(context, key, fallback)
                setOnClickListener {
                    send { done -> ShortcutEngine.cover(context, connectionId, ieee, action, done) }
                }
            }, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
        }
        root.addView(buttons)
        setContentView(root)
        setFinishOnTouchOutside(true)
        render()
    }

    override fun onStart() {
        super.onStart()
        ShortcutPrefs.listen(this, changes)
        render()
    }

    override fun onStop() {
        ShortcutPrefs.unlisten(this, changes)
        super.onStop()
    }

    private fun send(command: ((String) -> Unit) -> Unit) {
        line.text = ShortcutPrefs.word(this, "working", "working…")
        command { json ->
            android.util.Log.i("ZigDashShortcuts", "cover pop-up: $json")
            val outcome = try { org.json.JSONObject(json).optString("outcome") } catch (_: Exception) { "" }
            when (outcome) {
                "unreachable" -> line.text = ShortcutPrefs.word(this, "cantReach", "Can't reach home")
                "unconfirmed" -> line.text = ShortcutPrefs.word(this, "notConfirmed", "Not confirmed")
                else -> render()
            }
        }
    }

    private fun render() {
        line.text = ShortcutPrefs.state(this, connectionId, ieee)?.line ?: ""
        if (!dragging) {
            ShortcutPrefs.position(this, connectionId, ieee)?.let { slider?.progress = it }
        }
    }

    private fun dp(v: Int) = (v * resources.displayMetrics.density).toInt()

    companion object {
        const val EXTRA_HOME = "zigdash.home"
        const val EXTRA_IEEE = "zigdash.ieee"
        const val EXTRA_NAME = "zigdash.name"
        const val EXTRA_POSITION = "zigdash.position"

        fun intent(ctx: Context, t: ShortcutPrefs.Tile): Intent =
            Intent(ctx, CoverControlActivity::class.java)
                .putExtra(EXTRA_HOME, t.connectionId)
                .putExtra(EXTRA_IEEE, t.ieee)
                .putExtra(EXTRA_NAME, t.name)
                .putExtra(EXTRA_POSITION, t.position)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
    }
}
