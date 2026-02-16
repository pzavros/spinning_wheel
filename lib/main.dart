import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'core/ads/ad_unit_ids.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AdUnitIds.supportsAds) {
    try {
      await MobileAds.instance.initialize();
    } on PlatformException {
      // Keep the app usable when ads are unavailable in the current runtime.
    } on MissingPluginException {
      // Keep the app usable in test environments without plugin wiring.
    }
  }
  runApp(const ProviderScope(child: SpinMasterApp()));
}
