# Keep the app's native ad/platform-view classes (registered from
# MainActivity) intact during R8 shrinking.
-keep class com.nakudin.bagarawaapp.** { *; }

# Google Mobile Ads SDK ships its own consumer rules; these are safety nets.
-dontwarn com.google.android.gms.**
-keep class com.google.android.gms.ads.** { *; }

# Flutter engine JNI callbacks.
-keep class io.flutter.embedding.** { *; }
