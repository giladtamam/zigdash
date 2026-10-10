package com.giladtamam.zigdash

import android.content.Context
import org.json.JSONObject

/**
 * What the Dart side wrote for shortcuts, read from the shared_preferences
 * plugin's file (keys carry its "flutter." prefix):
 * - shortcut.tile.<slot>: {"connectionId","ieee","name"}
 * - shortcut.state.<connectionId>.<ieee>: {"line","on","at"}
 * - shortcut.strings: the native side's words, in the app's language.
 */
object ShortcutPrefs {
    private fun prefs(ctx: Context) =
        ctx.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    private fun json(ctx: Context, key: String): JSONObject? =
        prefs(ctx).getString("flutter.$key", null)?.let {
            try { JSONObject(it) } catch (_: Exception) { null }
        }

    data class Tile(
        val connectionId: String, val ieee: String, val name: String,
        val cover: Boolean = false, val position: Boolean = false,
        val deviceClass: String = "",
    ) {
        /** The tile and widget icon for this kind of device. */
        val icon: Int get() = when (deviceClass) {
            "cover" -> R.drawable.w_ic_cover
            "light", "colorLight" -> R.drawable.w_ic_light
            "switchPlug" -> R.drawable.w_ic_plug
            "climate", "contact", "motion", "leakSmoke" -> R.drawable.w_ic_sensor
            else -> R.drawable.ic_shortcut_tile
        }
    }

    data class State(val line: String?, val on: Boolean?, val at: Long?)

    fun tile(ctx: Context, slot: Int): Tile? = json(ctx, "shortcut.tile.$slot")?.let {
        Tile(it.optString("connectionId"), it.optString("ieee"), it.optString("name"),
            it.optBoolean("cover"), it.optBoolean("position"), it.optString("class"))
    }

    /** The shutter position (0–100) in the stored state payload, if any. */
    fun position(ctx: Context, connectionId: String, ieee: String): Int? =
        json(ctx, "shortcut.state.$connectionId.$ieee")?.optString("payload")?.let {
            try {
                val p = JSONObject(it)
                if (p.has("position")) p.optInt("position") else null
            } catch (_: Exception) { null }
        }

    fun state(ctx: Context, connectionId: String, ieee: String): State? =
        json(ctx, "shortcut.state.$connectionId.$ieee")?.let {
            State(
                it.optString("line").ifEmpty { null },
                if (it.has("on")) it.optBoolean("on") else null,
                if (it.has("at")) it.optLong("at") else null,
            )
        }

    fun listen(ctx: Context, l: android.content.SharedPreferences.OnSharedPreferenceChangeListener) =
        prefs(ctx).registerOnSharedPreferenceChangeListener(l)

    fun unlisten(ctx: Context, l: android.content.SharedPreferences.OnSharedPreferenceChangeListener) =
        prefs(ctx).unregisterOnSharedPreferenceChangeListener(l)

    /** The app's word for [key], or the English fallback. */
    fun word(ctx: Context, key: String, fallback: String): String =
        json(ctx, "shortcut.strings")?.optString(key)?.ifEmpty { null } ?: fallback
}
