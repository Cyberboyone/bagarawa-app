package com.nakudin.bagarawaapp

import android.util.Log
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : AudioServiceActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("bagarawa_banner_ad", BannerAdFactory(flutterEngine.dartExecutor.binaryMessenger))

        MobileAds.setRequestConfiguration(
            RequestConfiguration.Builder()
                .setTestDeviceIds(listOf("C2ADA274264F69C5F3937FD6E3F19F22"))
                .build()
        )

        MobileAds.initialize(this) { Log.d("BagarawaAds", "AdMob initialized") }
    }
}
