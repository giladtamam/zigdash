package com.giladtamam.zigdash

import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.text.format.DateUtils
import org.json.JSONObject

/**
 * A Quick Settings tile for one device (docs/design/roadmap-post-2.0.md,
 * 2.1 §2 and §4). ZigDash offers [SLOTS] fixed tiles; the app assigns each
 * slot to a device. A tap goes through [ShortcutEngine]: "working…" until
 * the device confirms, then its state; problems show for 10 s.
 */
abstract class ShortcutTileService : TileService() {
    abstract val slot: Int

    private val main = Handler(Looper.getMainLooper())
    private var flash: String? = null
    private var working = false

    // While the panel is open, redraw whenever the app or the engine writes
    // a new state (a shutter moving, a light switched from the dashboard).
    private val changes = android.content.SharedPreferences
        .OnSharedPreferenceChangeListener { _, key ->
            if (key != null && key.startsWith("flutter.shortcut.")) main.post { render() }
        }

    override fun onStartListening() {
        // The panel is open: start the engine now so a tap is quick.
        ShortcutEngine.warm(this)
        ShortcutPrefs.listen(this, changes)
        render()
    }

    override fun onStopListening() {
        ShortcutPrefs.unlisten(this, changes)
    }

    override fun onClick() {
        val t = ShortcutPrefs.tile(this, slot)
        if (t == null) {
            openApp(Intent(this, MainActivity::class.java)
                .putExtra(MainActivity.EXTRA_ACTION, "assignTile")
                .putExtra(MainActivity.EXTRA_SLOT, slot))
            return
        }
        // A shutter has a position, not on/off: open its slider pop-up.
        if (t.cover) {
            openApp(CoverControlActivity.intent(this, t))
            return
        }
        working = true
        flash = null
        render()
        val tap = System.currentTimeMillis()
        ShortcutEngine.toggle(this, t.connectionId, t.ieee) { json ->
            android.util.Log.i("ZigDashShortcuts",
                "tile $slot: ${System.currentTimeMillis() - tap} ms $json")
            working = false
            val outcome = try { JSONObject(json).optString("outcome") } catch (_: Exception) { "error" }
            flash = when (outcome) {
                "confirmed" -> null
                "unreachable" -> ShortcutPrefs.word(this, "cantReach", "Can't reach home")
                "unconfirmed" -> ShortcutPrefs.word(this, "notConfirmed", "Not confirmed")
                "removed" -> ShortcutPrefs.word(this, "removed", "Removed")
                else -> ShortcutPrefs.word(this, "notConfirmed", "Not confirmed")
            }
            render()
            if (flash != null) main.postDelayed({ flash = null; render() }, 10_000)
        }
    }

    private fun render() {
        val tile = qsTile ?: return
        val t = ShortcutPrefs.tile(this, slot)
        if (t == null) {
            tile.icon = android.graphics.drawable.Icon.createWithResource(this, R.drawable.ic_shortcut_tile)
            tile.label = "ZigDash"
            setSubtitle(tile, ShortcutPrefs.word(this, "chooseDevice", "Choose a device"))
            tile.state = Tile.STATE_INACTIVE
            tile.updateTile()
            return
        }
        val s = ShortcutPrefs.state(this, t.connectionId, t.ieee)
        tile.label = t.name
        tile.icon = ShortcutIcons.forTile(this, t)
        setSubtitle(tile, when {
            working -> ShortcutPrefs.word(this, "working", "working…")
            flash != null -> flash
            else -> withAge(s?.line, s?.at)
        })
        tile.state = if (s?.on == true) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        tile.updateTile()
    }

    /** The last-known line, with its age once it's over a minute old. */
    private fun withAge(line: String?, at: Long?): String? {
        if (line == null || at == null) return line
        val now = System.currentTimeMillis()
        if (now - at < DateUtils.MINUTE_IN_MILLIS) return line
        val age = DateUtils.getRelativeTimeSpanString(at, now, DateUtils.MINUTE_IN_MILLIS)
        return "$line · $age"
    }

    private fun setSubtitle(tile: Tile, text: String?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) tile.subtitle = text
    }

    private fun openApp(intent: Intent) {
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (Build.VERSION.SDK_INT >= 34) {
            startActivityAndCollapse(PendingIntent.getActivity(
                this, slot, intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT))
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }

    companion object {
        const val SLOTS = 4
    }
}

class ShortcutTile1 : ShortcutTileService() { override val slot = 1 }
class ShortcutTile2 : ShortcutTileService() { override val slot = 2 }
class ShortcutTile3 : ShortcutTileService() { override val slot = 3 }
class ShortcutTile4 : ShortcutTileService() { override val slot = 4 }
