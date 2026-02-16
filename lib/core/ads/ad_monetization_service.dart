import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_unit_ids.dart';

class AdMonetizationService {
  static const int spinsPerRewardedInterstitial = 2;

  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _loadingRewardedInterstitial = false;
  bool _showingRewardedInterstitial = false;
  int _spinsSinceLastInterstitial = 0;

  Future<void> initialize() async {
    if (!AdUnitIds.supportsAds) {
      return;
    }
    await _loadRewardedInterstitial();
  }

  Future<bool> registerCompletedSpin() async {
    _spinsSinceLastInterstitial += 1;
    if (_spinsSinceLastInterstitial < spinsPerRewardedInterstitial) {
      return false;
    }
    _spinsSinceLastInterstitial = 0;
    return _showRewardedInterstitialIfReady();
  }

  Future<void> registerWheelCreated({
    required int wheelCountBeforeCreate,
    required int wheelCountAfterCreate,
  }) async {
    final createdWheel = wheelCountAfterCreate > wheelCountBeforeCreate;
    final shouldMonetize =
        createdWheel &&
        wheelCountBeforeCreate > 1; // Skip the first user-created wheel.
    if (!shouldMonetize) {
      return;
    }
    await _showRewardedInterstitialIfReady();
  }

  Future<bool> _showRewardedInterstitialIfReady() async {
    if (!AdUnitIds.supportsAds || _showingRewardedInterstitial) {
      return false;
    }

    final ad = _rewardedInterstitialAd;
    if (ad == null) {
      await _loadRewardedInterstitial();
      return false;
    }

    final adClosedCompleter = Completer<void>();
    _rewardedInterstitialAd = null;
    _showingRewardedInterstitial = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _showingRewardedInterstitial = false;
        ad.dispose();
        _loadRewardedInterstitial();
        if (!adClosedCompleter.isCompleted) {
          adClosedCompleter.complete();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        _showingRewardedInterstitial = false;
        ad.dispose();
        _loadRewardedInterstitial();
        if (!adClosedCompleter.isCompleted) {
          adClosedCompleter.complete();
        }
      },
    );

    try {
      ad.show(onUserEarnedReward: (_, _) {});
      await adClosedCompleter.future;
      return true;
    } on PlatformException {
      _showingRewardedInterstitial = false;
      ad.dispose();
      await _loadRewardedInterstitial();
      return false;
    } on MissingPluginException {
      _showingRewardedInterstitial = false;
      ad.dispose();
      return false;
    }
  }

  Future<void> _loadRewardedInterstitial() async {
    if (!AdUnitIds.supportsAds || _loadingRewardedInterstitial) {
      return;
    }
    _loadingRewardedInterstitial = true;

    try {
      RewardedInterstitialAd.load(
        adUnitId: AdUnitIds.rewardedInterstitial,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback:
            RewardedInterstitialAdLoadCallback(
              onAdLoaded: (ad) {
                _loadingRewardedInterstitial = false;
                _rewardedInterstitialAd?.dispose();
                _rewardedInterstitialAd = ad;
              },
              onAdFailedToLoad: (_) {
                _loadingRewardedInterstitial = false;
              },
            ),
      );
    } on PlatformException {
      _loadingRewardedInterstitial = false;
    } on MissingPluginException {
      _loadingRewardedInterstitial = false;
    }
  }

  void dispose() {
    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
  }
}
