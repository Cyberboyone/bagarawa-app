package com.nakudin.bagarawaapp

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import java.util.ArrayDeque

/**
 * Preloads banner ads in the background so they are ready as soon as the
 * app UI needs them.
 *
 * - On init: if the device has any network (mobile data or Wi-Fi), a pool of
 *   ads is loaded immediately while the Flutter engine is still starting up.
 * - A NetworkCallback refills the pool whenever connectivity is regained,
 *   e.g. when mobile data is switched on.
 * - [BannerAdView] consumes ads from the pool via [pollAd]; every consumption
 *   triggers a refill so fresh ads keep loading in the background.
 */
object AdPreloader {

    const val AD_UNIT_ID = "ca-app-pub-9529770421530115/3303051802"

    private const val TAG = "BagarawaAds"
    private const val MAX_POOL_SIZE = 3

    private val mainHandler = Handler(Looper.getMainLooper())
    private val pool = ArrayDeque<AdView>()
    private var appContext: Context? = null
    private var callbackRegistered = false

    /** Call once from MainActivity after MobileAds.initialize(). */
    fun init(context: Context) {
        if (appContext != null) return
        appContext = context.applicationContext

        registerNetworkCallback()
        preloadIfOnline()
    }

    /** True when the device currently has internet access. */
    fun isOnline(): Boolean {
        val context = appContext ?: return false
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            ?: return false
        val network = cm.activeNetwork ?: return false
        val caps = cm.getNetworkCapabilities(network) ?: return false
        return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    }

    /**
     * Returns a pre-loaded ad if one is available, otherwise null.
     * Must be called from the main thread. Always triggers a background
     * refill afterwards.
     */
    fun pollAd(): AdView? {
        val ad = if (Looper.myLooper() == Looper.getMainLooper()) {
            pool.poll()
        } else {
            null
        }
        refillInBackground()
        return ad
    }

    /** Loads ads into the pool if we are online and the pool has room. */
    fun preloadIfOnline() {
        if (!isOnline()) {
            Log.d(TAG, "Preload skipped: no network connection")
            return
        }
        mainHandler.post { fillPool() }
    }

    private fun refillInBackground() {
        mainHandler.post { fillPool() }
    }

    private fun fillPool() {
        val context = appContext ?: return
        if (!isOnline()) return
        while (pool.size < MAX_POOL_SIZE) {
            pool.add(createAd(context))
        }
    }

    private fun createAd(context: Context): AdView {
        val adView = AdView(context)
        adView.adUnitId = AD_UNIT_ID
        adView.setAdSize(AdSize.BANNER)
        adView.loadAd(AdRequest.Builder().build())
        return adView
    }

    private fun registerNetworkCallback() {
        if (callbackRegistered) return
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return
        val context = appContext ?: return
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            ?: return
        try {
            cm.registerDefaultNetworkCallback(object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) {
                    Log.d(TAG, "Network available -> preloading ads")
                    preloadIfOnline()
                }
            })
            callbackRegistered = true
        } catch (e: Exception) {
            Log.w(TAG, "NetworkCallback registration failed: ${e.message}")
        }
    }
}
