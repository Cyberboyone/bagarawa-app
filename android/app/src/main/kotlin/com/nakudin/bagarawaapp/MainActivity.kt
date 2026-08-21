package com.nakudin.bagarawaapp

import android.util.Log
import com.google.android.gms.ads.MobileAds
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : AudioServiceActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("bagarawa_banner_ad", BannerAdFactory(flutterEngine.dartExecutor.binaryMessenger))

        // Initialize the Google Mobile Ads SDK and start pre-loading banner
        // ads in the background so they are ready as soon as the UI shows.
        MobileAds.initialize(this) {
            Log.d("BagarawaAds", "AdMob initialized")
            AdPreloader.init(this)
        }
        AdPreloader.init(this)
    }
}
