package com.giladtamam.zigdash

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/**
 * The foss build has no Play library and no install referrer
 * (docs/design/ha-link.md); the Dart side gets no answer and goes on.
 */
object InstallReferrer {
    fun register(@Suppress("UNUSED_PARAMETER") activity: Activity,
                 @Suppress("UNUSED_PARAMETER") messenger: BinaryMessenger) {}
}
