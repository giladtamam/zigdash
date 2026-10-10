package com.giladtamam.zigdash

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.RectF
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.drawable.Icon

/**
 * A shortcut's icon. Samsung's compact Quick Settings area shows a custom
 * tile as an icon only, so a named device gets its initials ("La" for Lavi,
 * "BR" for Bedroom roller) and the user can tell tiles apart; a device still
 * named by its address (0x…) gets its type's glyph. A small ZigDash logo in
 * the corner says whose tile it is. Drawn white on clear: Android tints tile
 * icons from their alpha.
 */
object ShortcutIcons {
    private val address = Regex("^0x[0-9a-fA-F]+$")

    fun initials(name: String): String? {
        val n = name.trim()
        if (n.isEmpty() || address.matches(n)) return null
        val words = n.split(Regex("[\\s_\\-]+")).filter { it.isNotEmpty() }
        // "Bedroom shutter 1" and "… 2" must differ: first letter + number.
        val number = words.last().takeIf { words.size >= 2 && it.all(Char::isDigit) }
        if (number != null) return words[0].take(1).uppercase() + number.take(2)
        return if (words.size >= 2) {
            (words[0].take(1) + words[1].take(1)).uppercase()
        } else {
            words[0].take(1).uppercase() + words[0].drop(1).take(1).lowercase()
        }
    }

    fun forTile(ctx: Context, t: ShortcutPrefs.Tile): Icon {
        val size = (48 * ctx.resources.displayMetrics.density).toInt()
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        // The content sits low and left, clear of the badge.
        val cx = size * 0.44f
        val cy = size * 0.58f
        val text = initials(t.name)
        if (text == null) {
            val glyph = ctx.getDrawable(t.icon)!!
            val half = (size * 0.32f).toInt()
            glyph.setBounds(cx.toInt() - half, cy.toInt() - half, cx.toInt() + half, cy.toInt() + half)
            glyph.setTint(Color.WHITE)
            glyph.draw(canvas)
        } else {
            val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.WHITE
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                textAlign = Paint.Align.CENTER
                textSize = size * (if (text.length > 1) 0.5f else 0.62f)
            }
            // Shrink long glyphs (wide letters, other scripts) to fit.
            val maxWidth = size * 0.76f
            val w = paint.measureText(text)
            if (w > maxWidth) paint.textSize *= maxWidth / w
            canvas.drawText(text, cx, cy - (paint.descent() + paint.ascent()) / 2f, paint)
        }
        drawBadge(canvas, size)
        return Icon.createWithBitmap(bmp)
    }

    /**
     * ZigDash's logo, small, in the top corner: four rounded squares with
     * the top-left one filled. Quick Settings shows custom tiles with no app
     * name, so this marks the tile as ZigDash's.
     */
    private fun drawBadge(canvas: Canvas, size: Int) {
        val cell = size * 0.11f
        val gap = size * 0.035f
        val stroke = size * 0.028f
        val left = size - 2 * cell - gap - size * 0.02f
        val top = size * 0.02f
        val r = cell * 0.3f
        val fill = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE }
        val line = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            style = Paint.Style.STROKE
            strokeWidth = stroke
        }
        for (row in 0..1) for (col in 0..1) {
            val x = left + col * (cell + gap)
            val y = top + row * (cell + gap)
            if (row == 0 && col == 0) {
                canvas.drawRoundRect(RectF(x, y, x + cell, y + cell), r, r, fill)
            } else {
                val h = stroke / 2
                canvas.drawRoundRect(RectF(x + h, y + h, x + cell - h, y + cell - h), r, r, line)
            }
        }
    }
}
