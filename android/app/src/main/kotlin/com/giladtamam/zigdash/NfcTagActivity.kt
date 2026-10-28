package com.giladtamam.zigdash

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.nfc.NdefMessage
import android.nfc.NfcAdapter
import android.os.Build
import android.os.Bundle

/**
 * A ZigDash NFC tag was tapped (3.3): runs its scene or toggles its device
 * through [WidgetActionService], like a widget tap, without opening the app.
 * Invisible, gone at once. The tag holds `zigdash://tag?h=<home>&a=scene|toggle&t=<id>&n=<label>`
 * and nothing secret: the phone's own saved Home does the rest.
 */
class NfcTagActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        tagUri(intent)?.let { uri ->
            val serial = NfcTags.hex(intent.getByteArrayExtra(NfcAdapter.EXTRA_ID))
            if (ShortcutPrefs.nfcTagOff(this, serial)) {
                // Turned off in the app's list of tags: ignored.
                android.widget.Toast.makeText(
                    this,
                    ShortcutPrefs.word(this, "nfcTagOff", "This tag is turned off in ZigDash"),
                    android.widget.Toast.LENGTH_SHORT,
                ).show()
            } else {
                ShortcutPrefs.nfcTagTapped(this, serial)
                run(uri)
            }
        }
        finish()
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

    private fun run(uri: Uri) {
        if (uri.scheme != SCHEME || uri.host != HOST) return
        val home = uri.getQueryParameter("h") ?: return
        val action = uri.getQueryParameter("a") ?: return
        val target = uri.getQueryParameter("t") ?: return
        if (action != "scene" && action != "toggle") return
        val label = uri.getQueryParameter("n") ?: ""
        startForegroundService(
            Intent(this, WidgetActionService::class.java)
                .setAction(WidgetActionService.ACTION_TAG)
                .putExtra(WidgetActionService.EXTRA_TAG_HOME, home)
                .putExtra(WidgetActionService.EXTRA_TAG_ACTION, action)
                .putExtra(WidgetActionService.EXTRA_TAG_TARGET, target)
                .putExtra(WidgetActionService.EXTRA_TAG_LABEL, label)
        )
    }

    companion object {
        const val SCHEME = "zigdash"
        const val HOST = "tag"
    }
}
