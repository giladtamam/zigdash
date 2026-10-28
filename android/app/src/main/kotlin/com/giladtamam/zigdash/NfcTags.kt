package com.giladtamam.zigdash

import android.app.Activity
import android.nfc.FormatException
import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.nfc.tech.NdefFormatable
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

/**
 * Writes ZigDash NFC tags (3.3). While the write sheet is open, reader mode
 * keeps Android from acting on a tag (ours included), and the first tag
 * held to the phone gets the link plus an app record, so a phone without
 * ZigDash opens its Play page (the link alone when the tag is too small).
 *
 * Channel "zigdash/nfc":
 *  - state  -> "on" | "off" (NFC turned off in Settings) | "none" (no NFC)
 *  - write  {uri} -> "written" | "readonly" | "too_small" | "unsupported" | "failed" (after a tag)
 *  - cancel -> stops waiting for a tag
 */
class NfcTags(private val activity: Activity, messenger: BinaryMessenger) {
    private val main = Handler(Looper.getMainLooper())
    private val adapter: NfcAdapter? = NfcAdapter.getDefaultAdapter(activity)
    private var pending: MethodChannel.Result? = null

    init {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "state" -> result.success(
                    when {
                        adapter == null -> "none"
                        adapter.isEnabled -> "on"
                        else -> "off"
                    }
                )
                "write" -> write(call.argument<String>("uri"), result)
                "cancel" -> {
                    stop()
                    pending?.success("cancelled")
                    pending = null
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun write(uri: String?, result: MethodChannel.Result) {
        val a = adapter
        if (a == null || !a.isEnabled || uri == null) {
            result.success("failed")
            return
        }
        pending?.success("cancelled")
        pending = result
        val link = NdefRecord.createUri(uri)
        val full = NdefMessage(
            arrayOf(link, NdefRecord.createApplicationRecord(activity.packageName))
        )
        // A small tag (NTAG213 holds 137 bytes) gets the link alone.
        val bare = NdefMessage(arrayOf(link))
        a.enableReaderMode(
            activity,
            { tag ->
                // Written already: the same tag held again does nothing.
                if (pending == null) return@enableReaderMode
                val outcome = writeTo(tag, full)
                finish(if (outcome == "too_small") writeTo(tag, bare) else outcome)
            },
            // No FLAG_READER_SKIP_NDEF_CHECK: without the NDEF check Android
            // offers neither Ndef nor NdefFormatable, and nothing can be
            // written (a MIFARE Classic sticker showed only MifareClassic, NfcA).
            NfcAdapter.FLAG_READER_NFC_A or NfcAdapter.FLAG_READER_NFC_B or
                NfcAdapter.FLAG_READER_NFC_F or NfcAdapter.FLAG_READER_NFC_V,
            null,
        )
    }

    private fun writeTo(tag: Tag, message: NdefMessage): String {
        Log.i(TAG, "tag ${tag.techList.joinToString()} message ${message.toByteArray().size} bytes")
        try {
            Ndef.get(tag)?.let { ndef ->
                ndef.connect()
                try {
                    Log.i(TAG, "ndef writable=${ndef.isWritable} max=${ndef.maxSize} type=${ndef.type}")
                    if (!ndef.isWritable) return "readonly"
                    if (ndef.maxSize < message.toByteArray().size) return "too_small"
                    ndef.writeNdefMessage(message)
                    return "written"
                } finally {
                    ndef.close()
                }
            }
            NdefFormatable.get(tag)?.let { f ->
                // A blank MIFARE Classic sticker on the S24 FE failed to
                // format with the message itself (IOException): format it
                // empty first, then write through Ndef like a formatted tag.
                f.connect()
                try {
                    f.format(NdefMessage(NdefRecord(NdefRecord.TNF_EMPTY, null, null, null)))
                } finally {
                    f.close()
                }
                Log.i(TAG, "formatted empty")
                val ndef = Ndef.get(tag) ?: return "failed"
                ndef.connect()
                try {
                    Log.i(TAG, "after format: max=${ndef.maxSize} type=${ndef.type}")
                    if (ndef.maxSize < message.toByteArray().size) return "too_small"
                    ndef.writeNdefMessage(message)
                    return "written"
                } finally {
                    ndef.close()
                }
            }
            return "unsupported"
        } catch (e: IOException) {
            Log.w(TAG, "write failed: $e")
            // A blank tag that can't take the full message reports an I/O
            // error rather than its size: the caller retries with the link alone.
            return if (NdefFormatable.get(tag) != null) "too_small" else "failed"
        } catch (e: FormatException) {
            Log.w(TAG, "write failed: $e")
            return "failed"
        }
    }

    // Reader mode stays on until the sheet closes ("cancel"): turned off
    // while the new tag still lies on the phone, Android would act on it at
    // once (found on the S24 FE: it opened the app the tag names).
    private fun finish(outcome: String) {
        main.post {
            pending?.success(outcome)
            pending = null
        }
    }

    private fun stop() {
        try {
            adapter?.disableReaderMode(activity)
        } catch (_: IllegalStateException) {
            // The activity is gone; reader mode went with it.
        }
    }

    companion object {
        const val CHANNEL = "zigdash/nfc"
        private const val TAG = "ZigDashNfc"

        fun register(activity: Activity, messenger: BinaryMessenger) {
            NfcTags(activity, messenger)
        }
    }
}
