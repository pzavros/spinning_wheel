import 'app_settings.dart';
import 'wheel_model.dart';

class AppState {
  const AppState({
    required this.wheels,
    required this.currentWheelId,
    required this.settings,
  });

  factory AppState.initial({required WheelModel starterWheel}) {
    return AppState(
      wheels: [starterWheel],
      currentWheelId: starterWheel.id,
      settings: AppSettings.defaults(),
    );
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    final wheels = (json['wheels'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => WheelModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return AppState(
      wheels: wheels,
      currentWheelId:
          json['currentWheelId'] as String? ??
          (wheels.isNotEmpty ? wheels.first.id : ''),
      settings: AppSettings.fromJson(
        json['settings'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }

  final List<WheelModel> wheels;
  final String currentWheelId;
  final AppSettings settings;

  WheelModel? get currentWheel {
    if (wheels.isEmpty) {
      return null;
    }
    return wheels.where((wheel) => wheel.id == currentWheelId).firstOrNull ??
        wheels.first;
  }

  AppState copyWith({
    List<WheelModel>? wheels,
    String? currentWheelId,
    AppSettings? settings,
  }) {
    return AppState(
      wheels: wheels ?? this.wheels,
      currentWheelId: currentWheelId ?? this.currentWheelId,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wheels': wheels.map((item) => item.toJson()).toList(),
      'currentWheelId': currentWheelId,
      'settings': settings.toJson(),
    };
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
