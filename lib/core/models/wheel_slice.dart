class WheelSlice {
  const WheelSlice({
    required this.id,
    required this.label,
    required this.colorValue,
    this.isHidden = false,
  });

  factory WheelSlice.fromJson(Map<String, dynamic> json) {
    return WheelSlice(
      id: json['id'] as String,
      label: json['label'] as String,
      colorValue: json['colorValue'] as int,
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }

  final String id;
  final String label;
  final int colorValue;
  final bool isHidden;

  WheelSlice copyWith({
    String? id,
    String? label,
    int? colorValue,
    bool? isHidden,
  }) {
    return WheelSlice(
      id: id ?? this.id,
      label: label ?? this.label,
      colorValue: colorValue ?? this.colorValue,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'colorValue': colorValue,
      'isHidden': isHidden,
    };
  }
}
