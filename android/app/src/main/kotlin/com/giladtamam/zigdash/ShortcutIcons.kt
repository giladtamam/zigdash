package com.giladtamam.zigdash

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.drawable.Icon

/**
 * A shortcut's icon. Samsung's compact Quick Settings area shows a custom
 * tile as an icon only, so a named device gets its initials ("La" for Lavi,
 * "BR" for Bedroom roller) and the user can tell tiles apart; a device still
 * named by its address (0x…) gets its type's glyph. Drawn white on clear:
 * Android tints tile icons from their alpha.
 */
object ShortcutIcons {
    private val address = Regex("^0x[0-9a-fA-F]+$")

    fun initials(name: String): String? {
        val n = name.trim()
        if (n.isEmpty() || address.matches(n)) return null
        val words = n.split(Regex("[\\s_\\-]+")).filter { it.isNotEmpty() }
        return if (words.size >= 2) {
            (words[0].take(1) + words[1].take(1)).uppercase()
        } else {
            words[0].take(1).uppercase() + words[0].drop(1).take(1).lowercase()
        }
    }

    fun forTile(ctx: Context, t: ShortcutPrefs.Tile): Icon {
        val text = initials(t.name) ?: return Icon.createWithResource(ctx, t.icon)
        val size = (48 * ctx.resources.displayMetrics.density).toInt()
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = android.graphics.Color.WHITE
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
            textSize = size * (if (text.length > 1) 0.56f else 0.7f)
        }
        // Shrink long glyphs (wide letters, other scripts) to fit.
        val maxWidth = size * 0.9f
        val w = paint.measureText(text)
        if (w > maxWidth) paint.textSize *= maxWidth / w
        val y = size / 2f - (paint.descent() + paint.ascent()) / 2f
        Canvas(bmp).drawText(text, size / 2f, y, paint)
        return Icon.createWithBitmap(bmp)
    }
}
