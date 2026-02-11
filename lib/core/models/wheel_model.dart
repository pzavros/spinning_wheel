import 'wheel_slice.dart';

class WheelModel {
  const WheelModel({
    required this.id,
    required this.name,
    required this.slices,
    required this.lastUsed,
  });

  factory WheelModel.fromJson(Map<String, dynamic> json) {
    return WheelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slices: (json['slices'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => WheelSlice.fromJson(item as Map<String, dynamic>))
          .toList(),
      lastUsed:
          DateTime.tryParse(json['lastUsed'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final String name;
  final List<WheelSlice> slices;
  final DateTime lastUsed;

  WheelModel copyWith({
    String? id,
    String? name,
    List<WheelSlice>? slices,
    DateTime? lastUsed,
  }) {
    return WheelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slices: slices ?? this.slices,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slices': slices.map((item) => item.toJson()).toList(),
      'lastUsed': lastUsed.toIso8601String(),
    };
  }
}
