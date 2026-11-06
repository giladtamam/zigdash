package com.giladtamam.zigdash

import android.app.Activity
import android.content.Intent
import android.os.Bundle

/**
 * Text shared to ZigDash from another app (docs/design/ha-share-paste.md):
 * the Home Assistant app's "Share server" link, or a page shared from a
 * browser, handed over instead of typing Home Assistant's address.
 *
 * Its own small activity, like the NFC tag's: a share starts its target
 * inside the sharing app's task, and the app itself has to open in its own.
 * It shows nothing, passes the text to [MainActivity] the way a shortcut
 * passes its request, and closes. Only text is taken, and no more of it
 * than an address could need.
 */
class ShareHaAddressActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val text = if (intent?.action == Intent.ACTION_SEND) {
            intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
        } else {
            null
        }
        startActivity(
            Intent(this, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                .putExtra(MainActivity.EXTRA_ACTION, "shareText")
                .putExtra(MainActivity.EXTRA_TEXT, (text ?: "").take(MAX_TEXT)),
        )
        finish()
    }

    companion object {
        const val MAX_TEXT = 2000
    }
}
