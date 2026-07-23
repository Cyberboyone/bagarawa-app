import 'dart:io' show Platform;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

/// Wraps Unity LevelPlay (formerly "Unity Ads") so the rest of the app
/// never talks to the ad SDK directly.
///
/// IMPORTANT - replace every placeholder below with the real IDs from your
/// Unity LevelPlay dashboard (https://dashboard.unity3d.com) before release.
class AdsService extends LevelPlayInitListener {
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

  /// Call once from main(). This never throws and never blocks app startup.
  Future<void> start() async {
    _tryInitAndLoadIfOnline();

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
    if (!online) return;

    _initializing = true;
    try {
      if (!_sdkInitialized) {
        final initRequest = LevelPlayInitRequest.builder(_appKey).build();
        await LevelPlay.init(initRequest: initRequest, initListener: this);
        _sdkInitialized = true;
      }

      _rewardedAd ??= LevelPlayRewardedAd(adUnitId: _rewardedAdUnitId);
      _interstitialAd ??= LevelPlayInterstitialAd(adUnitId: _interstitialAdUnitId);

      _rewardedAd?.loadAd();
      _interstitialAd?.loadAd();
    } catch (_) {
      // Never let ad-fetch problems surface to the listening experience.
    } finally {
      _initializing = false;
    }
  }

  // --- LevelPlayInitListener callbacks ---

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {}

  @override
  void onInitFailed(LevelPlayInitError error) {
    _sdkInitialized = false;
  }

  /// Show an interstitial at a natural break point.
  Future<void> showInterstitialIfReady() async {
    final ad = _interstitialAd;
    if (ad == null) return;
    if (await ad.isAdReady()) {
      await ad.showAd();
      ad.loadAd();
    }
  }

  /// Show a rewarded ad. [onReward] fires only if the user completes it.
  Future<void> showRewardedAd({required void Function() onReward}) async {
    final ad = _rewardedAd;
    if (ad == null) return;
    if (await ad.isAdReady()) {
      ad.setListener(_RewardedAdListener(onReward: onReward));
      await ad.showAd();
      ad.loadAd();
    }
  }
}

class _RewardedAdListener with LevelPlayRewardedAdListener {
  final void Function() onReward;

  _RewardedAdListener({required this.onReward});

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {}

  @override
  void onAdLoadFailed(LevelPlayAdError error) {}

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {}

  @override
  void onAdHidden(LevelPlayAdInfo adInfo) {}

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) {
    onReward();
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}
}
