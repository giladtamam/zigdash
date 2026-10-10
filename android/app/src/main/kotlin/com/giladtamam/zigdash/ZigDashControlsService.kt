package com.giladtamam.zigdash

import android.app.PendingIntent
import android.content.Intent
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import android.service.controls.Control
import android.service.controls.ControlsProviderService
import android.service.controls.DeviceTypes
import android.service.controls.actions.BooleanAction
import android.service.controls.actions.ControlAction
import android.service.controls.actions.FloatAction
import android.service.controls.templates.ControlButton
import android.service.controls.templates.ControlTemplate
import android.service.controls.templates.RangeTemplate
import android.service.controls.templates.ToggleRangeTemplate
import android.service.controls.templates.ToggleTemplate
import androidx.annotation.RequiresApi
import org.json.JSONObject
import java.util.concurrent.Flow
import java.util.function.Consumer
import kotlin.math.roundToInt

/**
 * Android's Device Controls (docs/design/roadmap-post-2.0.md, 2.1 §4): every
 * device on a dashboard, one control each, in a "ZigDash · <Home>"
 * structure. Lights, plugs and switches toggle; dimmable lights and shutters
 * get Android's slider; sensors show their reading. Commands and state go
 * through [ShortcutEngine], like the tiles; the app writes the device list
 * (shortcut.controls).
 */
@RequiresApi(30)
class ZigDashControlsService : ControlsProviderService() {
    private val main = Handler(Looper.getMainLooper())

    /** Open control panels; they follow the state the engine writes. */
    private val live = mutableSetOf<LiveSubscription>()
    private val working = mutableSetOf<String>()
    private val flash = mutableMapOf<String, String>()

    private val changes = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
        if (key == null || !key.startsWith("flutter.shortcut.state.")) return@OnSharedPreferenceChangeListener
        main.post { for (s in live.toList()) s.update(key.removePrefix("flutter.shortcut.state.")) }
    }

    override fun createPublisherForAllAvailable(): Flow.Publisher<Control> {
        val all = ShortcutPrefs.controls(this).map { e ->
            Control.StatelessBuilder(e.id, openIntent(e))
                .setTitle(e.name)
                .setStructure(structure(e))
                .setDeviceType(deviceType(e))
                .build()
        }
        return Flow.Publisher { s ->
            var sent = false
            s.onSubscribe(object : Flow.Subscription {
                override fun request(n: Long) {
                    if (sent) return
                    sent = true
                    all.forEach(s::onNext)
                    s.onComplete()
                }
                override fun cancel() {}
            })
        }
    }

    override fun createPublisherFor(controlIds: List<String>): Flow.Publisher<Control> {
        val wanted = ShortcutPrefs.controls(this).filter { it.id in controlIds }
        if (wanted.isNotEmpty()) ShortcutPrefs.mark(this, "shortcut.added.control", onlyOnce = true)
        return Flow.Publisher { s -> LiveSubscription(wanted, s).also(s::onSubscribe) }
    }

    override fun performControlAction(id: String, action: ControlAction, consumer: Consumer<Int>) {
        val e = ShortcutPrefs.controls(this).firstOrNull { it.id == id }
        if (e == null) {
            consumer.accept(ControlAction.RESPONSE_FAIL)
            return
        }
        consumer.accept(ControlAction.RESPONSE_OK)
        ShortcutPrefs.mark(this, "shortcut.used.control")
        main.post {
            working.add(id)
            flash.remove(id)
            push(e)
            val done = { json: String ->
                android.util.Log.i("ZigDashShortcuts", "control ${e.name}: $json")
                working.remove(id)
                val outcome = try { JSONObject(json).optString("outcome") } catch (_: Exception) { "" }
                val problem = when (outcome) {
                    "unreachable" -> ShortcutPrefs.word(this, "cantReach", "Can't reach home")
                    "unconfirmed" -> ShortcutPrefs.word(this, "notConfirmed", "Not confirmed")
                    "removed" -> ShortcutPrefs.word(this, "removed", "Removed")
                    else -> null
                }
                if (problem != null) {
                    flash[id] = problem
                    // Only the newest problem clears itself after 10 s.
                    main.removeCallbacksAndMessages(id.intern())
                    main.postAtTime({ flash.remove(id); push(e) }, id.intern(),
                        android.os.SystemClock.uptimeMillis() + 10_000)
                }
                push(e)
            }
            when (action) {
                is BooleanAction -> ShortcutEngine.set(this, e.connectionId, e.ieee, action.newState, done)
                is FloatAction -> ShortcutEngine.level(this, e.connectionId, e.ieee, action.newValue.roundToInt(), done)
                else -> done("{}")
            }
        }
    }

    private fun push(e: ShortcutPrefs.ControlEntry) {
        for (s in live.toList()) s.update("${e.connectionId}.${e.ieee}")
    }

    private fun stateful(e: ShortcutPrefs.ControlEntry): Control {
        val s = ShortcutPrefs.state(this, e.connectionId, e.ieee)
        val on = s?.on == true
        val level = (ShortcutPrefs.level(this, e.connectionId, e.ieee) ?: 0).coerceIn(0, 100).toFloat()
        val template = when {
            e.kind == "switch" || (e.kind == "cover" && !e.position) ->
                ToggleTemplate(e.id, ControlButton(on, e.name))
            e.kind == "dimmer" -> ToggleRangeTemplate(e.id, ControlButton(on, e.name),
                RangeTemplate("${e.id}/level", 0f, 100f, level, 1f, "%.0f%%"))
            e.kind == "cover" -> RangeTemplate(e.id, 0f, 100f, level, 1f, "%.0f%%")
            else -> ControlTemplate.getNoTemplateObject()
        }
        val status = when {
            e.id in working -> ShortcutPrefs.word(this, "working", "working…")
            flash[e.id] != null -> flash[e.id]!!
            // Android shows the slider's value after the text: leave the
            // percentage out of a sliding control's line ("Open", not
            // "Open · 100% 100%").
            hasRange(e) -> (s?.line ?: "").split(" · ").filterNot { '%' in it }.joinToString(" · ")
            else -> s?.line ?: ""
        }
        return Control.StatefulBuilder(e.id, openIntent(e))
            .setTitle(e.name)
            .setStructure(structure(e))
            .setDeviceType(deviceType(e))
            .setStatus(Control.STATUS_OK)
            .setStatusText(status)
            .setControlTemplate(template)
            .build()
    }

    private fun hasRange(e: ShortcutPrefs.ControlEntry) =
        e.kind == "dimmer" || (e.kind == "cover" && e.position)

    private fun structure(e: ShortcutPrefs.ControlEntry) ="ZigDash · ${e.home}"

    private fun deviceType(e: ShortcutPrefs.ControlEntry) = when (e.cls) {
        "light", "colorLight" -> DeviceTypes.TYPE_LIGHT
        "switchPlug" -> DeviceTypes.TYPE_OUTLET
        "cover" -> DeviceTypes.TYPE_BLINDS
        else -> if (e.kind == "sensor") DeviceTypes.TYPE_UNKNOWN else DeviceTypes.TYPE_GENERIC_ON_OFF
    }

    /** A long-press opens the device in ZigDash. */
    private fun openIntent(e: ShortcutPrefs.ControlEntry): PendingIntent =
        PendingIntent.getActivity(this, e.id.hashCode(),
            Intent(this, MainActivity::class.java)
                .putExtra(MainActivity.EXTRA_ACTION, "openDevice")
                .putExtra(MainActivity.EXTRA_HOME, e.connectionId)
                .putExtra(MainActivity.EXTRA_IEEE, e.ieee)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

    /** One open panel: sends each control as asked, then its changes. */
    private inner class LiveSubscription(
        private val entries: List<ShortcutPrefs.ControlEntry>,
        private val subscriber: Flow.Subscriber<in Control>,
    ) : Flow.Subscription {
        private var demand = 0L
        private val queue = ArrayDeque<Control>()
        private var started = false
        private var cancelled = false

        override fun request(n: Long) {
            main.post {
                if (cancelled) return@post
                demand = if (Long.MAX_VALUE - demand < n) Long.MAX_VALUE else demand + n
                if (!started) start()
                drain()
            }
        }

        override fun cancel() {
            main.post {
                cancelled = true
                live.remove(this)
                if (live.isEmpty()) ShortcutPrefs.unlisten(this@ZigDashControlsService, changes)
            }
        }

        private fun start() {
            started = true
            if (live.isEmpty()) ShortcutPrefs.listen(this@ZigDashControlsService, changes)
            live.add(this)
            entries.forEach { queue.add(stateful(it)) }
            // Ask the devices for their state now: shortcuts aren't
            // refreshed in the background.
            for ((home, list) in entries.groupBy { it.connectionId }) {
                ShortcutEngine.watch(this@ZigDashControlsService, home, list.map { it.ieee }) {}
            }
        }

        /** [key]: "<connectionId>.<ieee>", whose state changed. */
        fun update(key: String) {
            if (cancelled) return
            for (e in entries) {
                if ("${e.connectionId}.${e.ieee}" != key) continue
                queue.removeAll { it.controlId == e.id }
                queue.add(stateful(e))
            }
            drain()
        }

        private fun drain() {
            while (demand > 0 && queue.isNotEmpty()) {
                demand--
                subscriber.onNext(queue.removeFirst())
            }
        }
    }
}
