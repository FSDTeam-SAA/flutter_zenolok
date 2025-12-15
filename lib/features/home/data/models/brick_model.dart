class BrickModel {
  final String id;
  final String name;
  final String color; // Hex string like "#FF5722"
  final String icon;  // e.g. "ri-focus-2-fill"
  final String? createdBy;
  final List<String> participants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BrickModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.createdBy,
    this.participants = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory BrickModel.fromJson(Map<String, dynamic> json) {
    return BrickModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      createdBy: json['createdBy']?.toString(),
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      'icon': icon,
    };
  }
}
