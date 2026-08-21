package com.nakudin.bagarawaapp

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView

class BannerAdView(context: Context, messenger: BinaryMessenger, id: Int, params: Map<String, Any?>) : PlatformView {

    private val container = FrameLayout(context)

    init {
        // Serve a pre-loaded ad from the background pool when available so
        // banners render instantly; otherwise fall back to a fresh request.
        val adView = AdPreloader.pollAd() ?: createFreshAd(context)
        container.addView(adView)
    }

    private fun createFreshAd(context: Context): AdView {
        val adView = AdView(context)
        adView.adUnitId = AdPreloader.AD_UNIT_ID
        adView.setAdSize(AdSize.BANNER)
        adView.loadAd(AdRequest.Builder().build())
        return adView
    }

    override fun getView(): View = container

    override fun dispose() {
        val adView = container.getChildAt(0) as? AdView
        adView?.destroy()
    }
}
