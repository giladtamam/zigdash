package com.giladtamam.zigdash

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * The headless command engine shared by widgets, Quick Settings tiles and
 * Device Controls (docs/design/roadmap-post-2.0.md, 2.1 §1): one cached
 * FlutterEngine running lib/shortcuts/shortcut_engine.dart. Calls made before
 * Dart is ready wait in a queue. Main thread only.
 */
object ShortcutEngine {
    private const val TAG = "ZigDashShortcuts"
    private const val ID = "shortcuts"
    private var channel: MethodChannel? = null
    private var ready = false
    private val pending = mutableListOf<() -> Unit>()

    /** Starts the engine early (a tile does this when the panel opens). */
    fun warm(ctx: Context) = ensure(ctx.applicationContext)

    fun toggle(ctx: Context, connectionId: String, ieee: String, done: (String) -> Unit) =
        call(ctx, "toggle", mapOf("connectionId" to connectionId, "ieee" to ieee), done)

    /** A shutter's OPEN, STOP or CLOSE. */
    fun cover(ctx: Context, connectionId: String, ieee: String, action: String, done: (String) -> Unit) =
        call(ctx, "cover", mapOf("connectionId" to connectionId, "ieee" to ieee, "action" to action), done)

    /** A shutter's position, 0–100. */
    fun position(ctx: Context, connectionId: String, ieee: String, position: Int, done: (String) -> Unit) =
        call(ctx, "position", mapOf("connectionId" to connectionId, "ieee" to ieee, "position" to position), done)

    /** Device Controls: on or off. */
    fun set(ctx: Context, connectionId: String, ieee: String, on: Boolean, done: (String) -> Unit) =
        call(ctx, "set", mapOf("connectionId" to connectionId, "ieee" to ieee, "on" to on), done)

    /** Device Controls' slider: a shutter's position or a light's brightness. */
    fun level(ctx: Context, connectionId: String, ieee: String, level: Int, done: (String) -> Unit) =
        call(ctx, "level", mapOf("connectionId" to connectionId, "ieee" to ieee, "level" to level), done)

    /** Asks [ieees] for their state and follows them for a while. */
    fun watch(ctx: Context, connectionId: String, ieees: List<String>, done: (String) -> Unit) =
        call(ctx, "watch", mapOf("connectionId" to connectionId, "ieees" to ieees), done)

    fun scene(ctx: Context, connectionId: String, sceneId: String, done: (String) -> Unit) =
        call(ctx, "scene", mapOf("connectionId" to connectionId, "sceneId" to sceneId), done)

    private fun call(ctx: Context, method: String, args: Map<String, Any>, done: (String) -> Unit) {
        ensure(ctx.applicationContext)
        val run = {
            channel!!.invokeMethod(method, args, object : MethodChannel.Result {
                override fun success(result: Any?) = done(result as? String ?: "{}")
                override fun error(code: String, msg: String?, details: Any?) {
                    Log.e(TAG, "$method failed: $code $msg")
                    done("{\"outcome\":\"error\"}")
                }
                override fun notImplemented() = done("{\"outcome\":\"error\"}")
            })
        }
        if (ready) run() else pending.add(run)
    }

    private fun ensure(app: Context) {
        if (FlutterEngineCache.getInstance().get(ID) != null) return
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(app)
        loader.ensureInitializationComplete(app, null)
        val engine = FlutterEngine(app)
        val ch = MethodChannel(engine.dartExecutor.binaryMessenger, "zigdash/shortcuts")
        ch.setMethodCallHandler { call, result ->
            if (call.method == "ready") {
                ready = true
                pending.forEach { it() }
                pending.clear()
            }
            result.success(null)
        }
        channel = ch
        // Library-qualified: an entrypoint outside main.dart isn't found by
        // name alone.
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint(
            loader.findAppBundlePath(),
            "package:zigdash/shortcuts/shortcut_engine.dart", "shortcutEngine"))
        FlutterEngineCache.getInstance().put(ID, engine)
    }

    fun onMain(block: () -> Unit) = Handler(Looper.getMainLooper()).post(block)
}
