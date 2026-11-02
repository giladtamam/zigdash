package com.giladtamam.zigdash

import android.animation.ObjectAnimator
import android.app.Activity
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.nfc.NdefMessage
import android.nfc.NfcAdapter
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.animation.DecelerateInterpolator
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import org.json.JSONObject

/**
 * A ZigDash NFC tag was tapped (3.3): a sheet slides up over whatever is on
 * screen, with a short buzz, runs the tag's scene or toggles its device, and
 * shows the outcome: confirmed (closes by itself), a problem with Try again,
 * or that the tag is turned off. The tag holds
 * `zigdash://tag?h=<home>&a=scene|toggle&t=<target>&i=<tag id>` and nothing
 * secret: the phone's own saved Home does the rest.
 */
class NfcTagActivity : Activity() {
    private val main = Handler(Looper.getMainLooper())
    private lateinit var icon: TextView
    private lateinit var status: TextView
    private lateinit var body: TextView
    private lateinit var progress: ProgressBar
    private lateinit var actions: LinearLayout
    private lateinit var footer: TextView
    private lateinit var sheet: LinearLayout
    private var home = ""
    private var action = ""
    private var target = ""

    private val dark get() =
        (resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
    private val ground get() = if (dark) 0xFF1E1C18.toInt() else 0xFFFAF7F0.toInt()
    private val ink get() = if (dark) 0xFFF1ECE2.toInt() else 0xFF1E1C18.toInt()
    private val muted get() = if (dark) 0xFFB3AC9E.toInt() else 0xFF6B6558.toInt()
    private val line get() = if (dark) 0xFF4A463E.toInt() else 0xFFD8D2C4.toInt()
    private val problem get() = if (dark) 0xFFF09A8A.toInt() else 0xFFB3402E.toInt()
    private val accent = 0xFFE8A85A.toInt()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val uri = tagUri(intent)
        if (uri == null || uri.scheme != SCHEME || uri.host != HOST) {
            finish()
            return
        }
        home = uri.getQueryParameter("h").orEmpty()
        action = uri.getQueryParameter("a").orEmpty()
        target = uri.getQueryParameter("t").orEmpty()
        if (home.isEmpty() || target.isEmpty() || (action != "scene" && action != "toggle")) {
            finish()
            return
        }
        // The id ZigDash wrote into the link (the chip's serial number
        // changes at every read on some stickers).
        val id = uri.getQueryParameter("i").orEmpty()
        // Tags from before the list carried the name; newer ones are looked up.
        val label = uri.getQueryParameter("n") ?: ShortcutPrefs.nfcTagLabel(this, id)
        buzz()
        build(label.ifEmpty { "ZigDash" })
        if (ShortcutPrefs.nfcTagOff(this, id)) {
            showOff()
        } else {
            ShortcutPrefs.nfcTagTapped(this, id)
            ShortcutPrefs.mark(this, "shortcut.used.nfc_tag")
            runAction()
        }
    }

    private fun word(key: String, fallback: String) = ShortcutPrefs.word(this, key, fallback)

    private fun dp(v: Float) = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v, resources.displayMetrics)
    private fun dpi(v: Int) = dp(v.toFloat()).toInt()

    private fun text(size: Float, color: Int, bold: Boolean = false) = TextView(this).apply {
        setTextSize(TypedValue.COMPLEX_UNIT_SP, size)
        setTextColor(color)
        if (bold) typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
    }

    private fun build(label: String) {
        val root = FrameLayout(this).apply {
            setBackgroundColor(0x73080807)
            setOnClickListener { close() }
        }
        sheet = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = GradientDrawable().apply {
                setColor(ground)
                cornerRadii = floatArrayOf(dp(28f), dp(28f), dp(28f), dp(28f), 0f, 0f, 0f, 0f)
            }
            setPadding(dpi(24), dpi(12), dpi(24), dpi(28))
            // Taps on the sheet stay on it; outside it, they close it.
            isClickable = true
        }
        sheet.addView(
            View(this).apply { background = GradientDrawable().apply { setColor(line); cornerRadius = dp(2f) } },
            LinearLayout.LayoutParams(dpi(36), dpi(4)).apply { gravity = Gravity.CENTER_HORIZONTAL; bottomMargin = dpi(18) },
        )

        val row = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL; gravity = Gravity.CENTER_VERTICAL }
        icon = text(22f, accent, bold = true).apply { gravity = Gravity.CENTER }
        row.addView(icon, LinearLayout.LayoutParams(dpi(52), dpi(52)).apply { marginEnd = dpi(16) })
        val col = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }
        col.addView(text(12f, muted, bold = true).apply {
            text = word("nfcTagHeader", "ZigDash tag").uppercase()
            letterSpacing = 0.08f
        })
        col.addView(text(21f, ink, bold = true).apply { text = label; textDirection = View.TEXT_DIRECTION_FIRST_STRONG })
        status = text(15f, muted)
        col.addView(status)
        row.addView(col, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
        sheet.addView(row)

        progress = ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal).apply {
            isIndeterminate = true
            indeterminateTintList = android.content.res.ColorStateList.valueOf(accent)
        }
        sheet.addView(progress, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dpi(6)).apply { topMargin = dpi(16) })
        body = text(14f, muted).apply { visibility = View.GONE; setLineSpacing(0f, 1.3f) }
        sheet.addView(body, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = dpi(14) })
        actions = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL; visibility = View.GONE }
        sheet.addView(actions, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = dpi(16) })
        footer = text(13f, muted).apply { visibility = View.GONE }
        sheet.addView(footer, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = dpi(12) })

        root.addView(sheet, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.BOTTOM))
        setContentView(root)
        sheet.post {
            sheet.translationY = sheet.height.toFloat()
            ObjectAnimator.ofFloat(sheet, View.TRANSLATION_Y, 0f).apply {
                duration = 240
                interpolator = DecelerateInterpolator()
                start()
            }
        }
    }

    private fun setIcon(symbol: String, color: Int, filled: Boolean) {
        icon.text = symbol
        icon.setTextColor(if (filled) ground else color)
        icon.background = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(if (filled) color else (color and 0x00FFFFFF) or 0x26000000)
        }
    }

    private fun runAction() {
        setIcon("◉", accent, filled = false)
        status.setTextColor(muted)
        status.text = if (action == "scene") word("nfcTagRunning", "Running…") else word("nfcTagSwitching", "Switching…")
        progress.visibility = View.VISIBLE
        body.visibility = View.GONE
        actions.visibility = View.GONE
        footer.visibility = View.GONE
        val done = { json: String ->
            android.util.Log.i("ZigDashShortcuts", "nfc tag $action: $json")
            main.post { showResult(json) }
            Unit
        }
        if (action == "scene") ShortcutEngine.scene(this, home, target, done) else ShortcutEngine.toggle(this, home, target, done)
    }

    private fun showResult(json: String) {
        if (isFinishing) return
        val o = try { JSONObject(json) } catch (_: Exception) { JSONObject() }
        val outcome = o.optString("outcome")
        progress.visibility = View.GONE
        if (outcome == "confirmed" || outcome == "sent") {
            setIcon("✓", accent, filled = true)
            status.setTextColor(muted)
            status.text = o.optString("line").ifEmpty { word("nfcTagDone", "Done") }
            footer.text = word("nfcTagClosing", "Closes in 2 seconds")
            footer.visibility = View.VISIBLE
            main.postDelayed({ close() }, 2_000)
            return
        }
        setIcon("!", problem, filled = false)
        status.setTextColor(problem)
        status.text = when (outcome) {
            "unreachable" -> word("cantReach", "Can't reach home")
            "removed" -> word("removed", "Removed")
            else -> word("notConfirmed", "Not confirmed")
        }
        if (outcome == "unreachable") {
            body.text = word("nfcTagUnreachableBody", "This phone can't reach the home right now. Check the Wi-Fi, or turn on remote control.")
            body.visibility = View.VISIBLE
        }
        buttons(word("retry", "Try again") to { runAction() })
    }

    private fun showOff() {
        progress.visibility = View.GONE
        setIcon("⊘", muted, filled = false)
        status.text = word("nfcTagOff", "This tag is turned off")
        body.text = word("nfcTagOffBody", "Nothing was switched. Turn it back on in the Home's settings, under NFC tags.")
        body.visibility = View.VISIBLE
        buttons(null)
    }

    /** A filled [primary] button (if any) and Open ZigDash. */
    private fun buttons(primary: Pair<String, () -> Unit>?) {
        actions.removeAllViews()
        fun pill(label: String, filled: Boolean, onClick: () -> Unit) = Button(this).apply {
            text = label
            isAllCaps = false
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            setTextColor(if (filled) 0xFF1E1C18.toInt() else ink)
            stateListAnimator = null
            background = GradientDrawable().apply {
                cornerRadius = dp(24f)
                if (filled) setColor(accent) else { setColor(Color.TRANSPARENT); setStroke(dpi(1), line) }
            }
            setOnClickListener { onClick() }
        }
        primary?.let { (label, onClick) ->
            actions.addView(pill(label, true, onClick), LinearLayout.LayoutParams(0, dpi(48), 1f).apply { marginEnd = dpi(10) })
        }
        val open = pill(word("nfcTagOpenApp", "Open ZigDash"), primary == null) {
            startActivity(Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            close()
        }
        open.setPadding(dpi(20), 0, dpi(20), 0)
        actions.addView(
            open,
            if (primary == null) LinearLayout.LayoutParams(0, dpi(48), 1f)
            else LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, dpi(48)),
        )
        actions.visibility = View.VISIBLE
    }

    private fun close() {
        if (isFinishing) return
        ObjectAnimator.ofFloat(sheet, View.TRANSLATION_Y, sheet.height.toFloat()).apply {
            duration = 180
            start()
        }
        main.postDelayed({
            finish()
            @Suppress("DEPRECATION")
            overridePendingTransition(0, 0)
        }, 180)
    }

    private fun buzz() {
        val v = if (Build.VERSION.SDK_INT >= 31) {
            (getSystemService(VIBRATOR_MANAGER_SERVICE) as android.os.VibratorManager).defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(VIBRATOR_SERVICE) as android.os.Vibrator
        }
        v.vibrate(android.os.VibrationEffect.createPredefined(android.os.VibrationEffect.EFFECT_CLICK))
    }

    private fun tagUri(intent: Intent?): Uri? {
        if (intent?.action != NfcAdapter.ACTION_NDEF_DISCOVERED) return null
        intent.data?.let { return it }
        val messages = if (Build.VERSION.SDK_INT >= 33) {
            intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES, NdefMessage::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)?.filterIsInstance<NdefMessage>()?.toTypedArray()
        }
        for (m in messages ?: emptyArray()) {
            for (r in m.records) r.toUri()?.let { if (it.scheme == SCHEME) return it }
        }
        return null
    }

    companion object {
        const val SCHEME = "zigdash"
        const val HOST = "tag"
    }
}
