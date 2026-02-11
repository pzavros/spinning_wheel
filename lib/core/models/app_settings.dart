import 'package:flutter/material.dart';

enum BackgroundIntensity { low, medium, high }

enum AppThemePreference { system, light, dark }

class AppSettings {
  const AppSettings({
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.removeWinner,
    required this.backgroundIntensity,
    required this.themePreference,
    required this.wheelSpeedLevel,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      soundEnabled: true,
      hapticsEnabled: true,
      removeWinner: false,
      backgroundIntensity: BackgroundIntensity.medium,
      themePreference: AppThemePreference.system,
      wheelSpeedLevel: 5,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawWheelSpeedLevel = json['wheelSpeedLevel'];
    final legacyWheelSpeed = json['wheelSpeed'] as String?;

    int wheelSpeedLevel;
    if (rawWheelSpeedLevel is num) {
      wheelSpeedLevel = rawWheelSpeedLevel.round().clamp(1, 10).toInt();
    } else {
      switch (legacyWheelSpeed) {
        case 'slow':
          wheelSpeedLevel = 2;
        case 'fast':
          wheelSpeedLevel = 8;
        case 'normal':
        default:
          wheelSpeedLevel = 5;
      }
    }

    return AppSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      removeWinner: json['removeWinner'] as bool? ?? false,
      backgroundIntensity: BackgroundIntensity.values.byName(
        json['backgroundIntensity'] as String? ??
            BackgroundIntensity.medium.name,
      ),
      themePreference: AppThemePreference.values.byName(
        json['themePreference'] as String? ?? AppThemePreference.system.name,
      ),
      wheelSpeedLevel: wheelSpeedLevel,
    );
  }

  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool removeWinner;
  final BackgroundIntensity backgroundIntensity;
  final AppThemePreference themePreference;
  final int wheelSpeedLevel;

  ThemeMode get themeMode {
    switch (themePreference) {
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.system:
        return ThemeMode.system;
    }
  }

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? removeWinner,
    BackgroundIntensity? backgroundIntensity,
    AppThemePreference? themePreference,
    int? wheelSpeedLevel,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      removeWinner: removeWinner ?? this.removeWinner,
      backgroundIntensity: backgroundIntensity ?? this.backgroundIntensity,
      themePreference: themePreference ?? this.themePreference,
      wheelSpeedLevel: (wheelSpeedLevel ?? this.wheelSpeedLevel)
          .clamp(1, 10)
          .toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
      'removeWinner': removeWinner,
      'backgroundIntensity': backgroundIntensity.name,
      'themePreference': themePreference.name,
      'wheelSpeedLevel': wheelSpeedLevel,
    };
  }
}
