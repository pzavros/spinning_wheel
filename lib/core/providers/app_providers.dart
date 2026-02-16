import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ads/ad_monetization_service.dart';
import '../controller/app_controller.dart';
import '../models/app_state.dart';
import '../storage/app_storage.dart';

final appStorageProvider = Provider<AppStorage>((ref) => AppStorage());

final appControllerProvider = AsyncNotifierProvider<AppController, AppState>(
  AppController.new,
);

final adMonetizationServiceProvider = Provider<AdMonetizationService>((ref) {
  final service = AdMonetizationService();
  unawaited(service.initialize());
  ref.onDispose(service.dispose);
  return service;
});
