import 'dart:io' show Platform;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

/// Wraps Unity LevelPlay (formerly "Unity Ads") so the rest of the app
/// never talks to the ad SDK directly.
///
/// Design intent for this app: listening to audio is 100% offline and
/// must never depend on network or ads in any way. Ads are a bonus
/// revenue layer that quietly preload in the background *only* when the
/// device has data - and are shown at natural break points (never mid-
/// playback). If there's no connection, the app just runs ad-free for
/// that session; nothing blocks, nothing errors out to the user.
///
/// IMPORTANT - replace every placeholder below with the real IDs from your
/// Unity LevelPlay dashboard (https://dashboard.unity3d.com) before release.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  // --- Replace with your real app keys ---
  static const String _appKeyAndroid = 'YOUR_ANDROID_APP_KEY';
  static const String _appKeyIOS = 'YOUR_IOS_APP_KEY';

  // --- Replace with your real ad unit IDs ---
  static const String _rewardedAdUnitAndroid = 'YOUR_ANDROID_REWARDED_UNIT_ID';
  static const String _rewardedAdUnitIOS = 'YOUR_IOS_REWARDED_UNIT_ID';

  static const String _interstitialAdUnitAndroid = 'YOUR_ANDROID_INTERSTITIAL_UNIT_ID';
  static const String _interstitialAdUnitIOS = 'YOUR_IOS_INTERSTITIAL_UNIT_ID';

  LevelPlayRewardedAd? _rewardedAd;
  LevelPlayInterstitialAd? _interstitialAd;

  bool _sdkInitialized = false;
  bool _initializing = false;

  final Connectivity _connectivity = Connectivity();

  String get _appKey => Platform.isIOS ? _appKeyIOS : _appKeyAndroid;
  String get _rewardedAdUnitId =>
      Platform.isIOS ? _rewardedAdUnitIOS : _rewardedAdUnitAndroid;
  String get _interstitialAdUnitId =>
      Platform.isIOS ? _interstitialAdUnitIOS : _interstitialAdUnitAndroid;

  /// Call once from main(). This never throws and never blocks app
  /// startup - it just kicks off background work and returns immediately.
  Future<void> start() async {
    // Try once right away in case data is already on...
    _tryInitAndLoadIfOnline();

    // ...and keep listening so we pick up ads as soon as data turns on,
    // even mid-session (e.g. user was offline, then connects to wifi).
    _connectivity.onConnectivityChanged.listen((results) {
      final hasConnection =
          results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        _tryInitAndLoadIfOnline();
      }
    });
  }

  Future<void> _tryInitAndLoadIfOnline() async {
    if (_initializing) return;

    final result = await _connectivity.checkConnectivity();
    final online = result.any((r) => r != ConnectivityResult.none);
    if (!online) return; // stay silent - fully expected when offline

    _initializing = true;
    try {
      if (!_sdkInitialized) {
        await LevelPlay.init(appKey: _appKey, legacyAdFormats: []);
        _sdkInitialized = true;
      }

      _rewardedAd ??= LevelPlayRewardedAd(adUnitId: _rewardedAdUnitId);
      _interstitialAd ??= LevelPlayInterstitialAd(adUnitId: _interstitialAdUnitId);

      // Preload in the background. Failures here (e.g. flaky connection)
      // are swallowed - we just try again next time connectivity changes.
      _rewardedAd?.loadAd();
      _interstitialAd?.loadAd();
    } catch (_) {
      // Never let ad-fetch problems surface to the listening experience.
    } finally {
      _initializing = false;
    }
  }

  /// Show an interstitial at a natural break point - e.g. after a lesson
  /// finishes, before returning to the library screen. Does nothing (and
  /// never blocks) if no ad happened to preload in time.
  Future<void> showInterstitialIfReady() async {
    final ad = _interstitialAd;
    if (ad == null) return;
    if (await ad.isAdReady()) {
      await ad.showAd();
      ad.loadAd(); // preload the next one for later
    }
  }

  /// Show a rewarded ad, e.g. to unlock a bonus lecture or offline
  /// download. [onReward] fires only if the user actually completes it.
  /// If no ad is ready (e.g. no connection this session), this simply
  /// does nothing - callers should design the unlock flow so that's fine.
  Future<void> showRewardedAd({required void Function() onReward}) async {
    final ad = _rewardedAd;
    if (ad == null) return;
    if (await ad.isAdReady()) {
      ad.setListener(
        LevelPlayRewardedAdListener(
          onAdRewarded: (adInfo, reward) => onReward(),
        ),
      );
      await ad.showAd();
      ad.loadAd();
    }
  }
}
