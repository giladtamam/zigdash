package com.giladtamam.zigdash

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import org.json.JSONObject

/**
 * Runs a home-screen widget tap (docs/design/roadmap-post-2.0.md, 2.1 §1:
 * "widget taps run as a short user-initiated foreground task", because
 * Android 16 can block network for an idle app). It sends the command
 * through [ShortcutEngine], redraws the widget as the device answers, keeps
 * a problem on screen for 10 s, and follows a moving shutter until the
 * engine stops writing (at most [FOLLOW_MS]).
 */
class WidgetActionService : Service() {
    private val main = Handler(Looper.getMainLooper())
    private var running = 0
    private val changes = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
        if (key != null && key.startsWith("flutter.shortcut.state.")) {
            main.post { DeviceWidget.refreshAll(this) }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        ShortcutPrefs.listen(this, changes)
    }

    override fun onDestroy() {
        ShortcutPrefs.unlisten(this, changes)
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground()
        val id = intent?.getIntExtra(DeviceWidget.EXTRA_ID, -1) ?: -1
        val action = intent?.action ?: ""
        val t = ShortcutPrefs.widget(this, id)
        if (t == null) {
            finishSoon(0)
            return START_NOT_STICKY
        }
        ShortcutPrefs.mark(this, "shortcut.used.widget")
        val mgr = AppWidgetManager.getInstance(this)
        DeviceWidget.render(this, mgr, id, working = true)
        running++
        val done = { json: String ->
            android.util.Log.i("ZigDashShortcuts", "widget $id $action: $json")
            val outcome = try { JSONObject(json).optString("outcome") } catch (_: Exception) { "" }
            val problem = when (outcome) {
                "confirmed", "sent" -> null
                "unreachable" -> ShortcutPrefs.word(this, "cantReach", "Can't reach home")
                "removed" -> ShortcutPrefs.word(this, "removed", "Removed")
                else -> ShortcutPrefs.word(this, "notConfirmed", "Not confirmed")
            }
            DeviceWidget.render(this, mgr, id, problem = problem)
            running--
            // A problem stays 10 s; a shutter that started moving is
            // followed by the engine, which writes its state as it goes.
            finishSoon(when {
                problem != null -> 10_000L
                t.cover -> FOLLOW_MS
                else -> 0L
            }, redraw = problem != null)
        }
        when (action) {
            "TOGGLE" -> ShortcutEngine.toggle(this, t.connectionId, t.ieee, done)
            "OPEN", "STOP", "CLOSE" -> ShortcutEngine.cover(this, t.connectionId, t.ieee, action, done)
            else -> done("{}")
        }
        return START_NOT_STICKY
    }

    private fun finishSoon(delay: Long, redraw: Boolean = false) {
        main.postDelayed({
            if (redraw) DeviceWidget.refreshAll(this)
            if (running == 0) stopSelf()
        }, delay)
    }

    // shortService (Android 14+) allows about three minutes; a tap takes
    // seconds.
    override fun onTimeout(startId: Int) {
        stopSelf()
    }

    private fun startForeground() {
        val nm = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= 26 && nm.getNotificationChannel(CHANNEL) == null) {
            nm.createNotificationChannel(NotificationChannel(CHANNEL,
                ShortcutPrefs.word(this, "working", "working…"), NotificationManager.IMPORTANCE_MIN))
        }
        val n = (if (Build.VERSION.SDK_INT >= 26) Notification.Builder(this, CHANNEL)
                 else @Suppress("DEPRECATION") Notification.Builder(this))
            .setSmallIcon(R.drawable.ic_shortcut_tile)
            .setContentTitle(ShortcutPrefs.word(this, "working", "working…"))
            .build()
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(NOTIFICATION, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_SHORT_SERVICE)
        } else {
            startForeground(NOTIFICATION, n)
        }
    }

    companion object {
        private const val CHANNEL = "shortcuts"
        private const val NOTIFICATION = 21
        private const val FOLLOW_MS = 45_000L
    }
}
