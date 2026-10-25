package com.giladtamam.zigdash

import android.content.Context
import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.os.Build
import android.os.Handler
import android.os.Looper
import java.net.Inet4Address
import java.net.InetAddress

/**
 * Finds services on the home network by DNS-SD (3.1.8): Home Assistant
 * announces itself as `_home-assistant._tcp`, with its addresses in the
 * TXT record. Android's NsdManager does the multicast, so this works where
 * a `.local` name doesn't resolve. Each service is resolved to an IP, one
 * at a time (resolving two at once fails before Android 14).
 */
class ServiceFinder(context: Context) {
    private val nsd = context.getSystemService(Context.NSD_SERVICE) as NsdManager
    private val main = Handler(Looper.getMainLooper())

    /** The services of [type] found within [timeoutMs]; never fails. */
    fun find(type: String, timeoutMs: Long, done: (List<Map<String, Any>>) -> Unit) {
        val found = mutableListOf<Map<String, Any>>()
        val queue = ArrayDeque<NsdServiceInfo>()
        var resolving = false
        var finished = false

        fun resolveNext() {
            if (finished || resolving) return
            val next = queue.removeFirstOrNull() ?: return
            resolving = true
            @Suppress("DEPRECATION")
            nsd.resolveService(next, object : NsdManager.ResolveListener {
                override fun onResolveFailed(info: NsdServiceInfo, code: Int) {
                    main.post { resolving = false; resolveNext() }
                }

                override fun onServiceResolved(info: NsdServiceInfo) {
                    main.post {
                        resolving = false
                        if (!finished) describe(info)?.let { found.add(it) }
                        resolveNext()
                    }
                }
            })
        }

        val listener = object : NsdManager.DiscoveryListener {
            override fun onDiscoveryStarted(serviceType: String) {}
            override fun onDiscoveryStopped(serviceType: String) {}
            override fun onStartDiscoveryFailed(serviceType: String, code: Int) {}
            override fun onStopDiscoveryFailed(serviceType: String, code: Int) {}
            override fun onServiceLost(info: NsdServiceInfo) {}
            override fun onServiceFound(info: NsdServiceInfo) {
                main.post { queue.addLast(info); resolveNext() }
            }
        }
        try {
            nsd.discoverServices(type, NsdManager.PROTOCOL_DNS_SD, listener)
        } catch (_: Exception) {
            done(emptyList())
            return
        }
        main.postDelayed({
            finished = true
            try { nsd.stopServiceDiscovery(listener) } catch (_: Exception) {}
            done(found.distinctBy { "${it["host"]}:${it["port"]}" })
        }, timeoutMs)
    }

    private fun describe(info: NsdServiceInfo): Map<String, Any>? {
        val host = address(info)?.hostAddress ?: return null
        val txt = mutableMapOf<String, String>()
        for ((k, v) in info.attributes) {
            if (v != null) txt[k] = String(v, Charsets.UTF_8)
        }
        return mapOf(
            "name" to (info.serviceName ?: ""),
            "host" to host,
            "port" to info.port,
            "txt" to txt,
        )
    }

    /** An IPv4 address when there is one: easier to type and to read. */
    private fun address(info: NsdServiceInfo): InetAddress? {
        if (Build.VERSION.SDK_INT >= 34) {
            val all = info.hostAddresses
            return all.firstOrNull { it is Inet4Address } ?: all.firstOrNull()
        }
        @Suppress("DEPRECATION")
        return info.host
    }
}
