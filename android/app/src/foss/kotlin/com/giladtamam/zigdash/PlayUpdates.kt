package com.giladtamam.zigdash

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/**
 * The foss build (GitHub, IzzyOnDroid, F-Droid) has no Play library: its
 * stores update it. The Dart side knows from ZIGDASH_FLAVOR and never asks.
 */
object PlayUpdates {
    fun register(@Suppress("UNUSED_PARAMETER") activity: Activity,
                 @Suppress("UNUSED_PARAMETER") messenger: BinaryMessenger) {}
}
