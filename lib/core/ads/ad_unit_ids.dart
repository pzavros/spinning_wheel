import 'package:flutter/foundation.dart';

class AdUnitIds {
  static const String _androidBannerTest =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosBannerTest =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _androidRewardedInterstitialTest =
      'ca-app-pub-3940256099942544/5354046379';
  static const String _iosRewardedInterstitialTest =
      'ca-app-pub-3940256099942544/6978759866';
  static const String _androidRewardedProd = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID',
    defaultValue: 'ca-app-pub-7337235093373583/9320398619',
  );
  static const String _iosRewardedProd = String.fromEnvironment(
    'ADMOB_REWARDED_IOS',
  );

  static const String _androidBannerProd = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
    defaultValue: 'ca-app-pub-7337235093373583/8969044827',
  );
  static const String _iosBannerProd = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
  );
  static const String _androidRewardedInterstitialProd =
      String.fromEnvironment(
        'ADMOB_REWARDED_INTERSTITIAL_ANDROID',
        defaultValue: 'ca-app-pub-7337235093373583/3925533916',
      );
  static const String _iosRewardedInterstitialProd = String.fromEnvironment(
    'ADMOB_REWARDED_INTERSTITIAL_IOS',
  );

  static bool get supportsAds {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static String get banner {
    if (!kReleaseMode) {
      return _platformValue(
        androidValue: _androidBannerTest,
        iosValue: _iosBannerTest,
      );
    }

    return _platformValue(
      androidValue: _androidBannerProd.isNotEmpty
          ? _androidBannerProd
          : _androidBannerTest,
      iosValue: _iosBannerProd.isNotEmpty ? _iosBannerProd : _iosBannerTest,
    );
  }

  static String get rewardedInterstitial {
    if (!kReleaseMode) {
      return _platformValue(
        androidValue: _androidRewardedInterstitialTest,
        iosValue: _iosRewardedInterstitialTest,
      );
    }

    return _platformValue(
      androidValue: _androidRewardedInterstitialProd.isNotEmpty
          ? _androidRewardedInterstitialProd
          : _androidRewardedInterstitialTest,
      iosValue: _iosRewardedInterstitialProd.isNotEmpty
          ? _iosRewardedInterstitialProd
          : _iosRewardedInterstitialTest,
    );
  }

  static String get rewarded {
    return _platformValue(
      androidValue: _androidRewardedProd,
      iosValue: _iosRewardedProd,
    );
  }

  static String _platformValue({
    required String androidValue,
    required String iosValue,
  }) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidValue;
      case TargetPlatform.iOS:
        return iosValue;
      default:
        return '';
    }
  }
}
