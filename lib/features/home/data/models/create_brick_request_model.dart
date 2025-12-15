class CreateBrickRequestModel {
  final String name;
  final String color; // hex "#RRGGBB"
  final String icon;  // e.g. "ri-focus-2-fill"

  CreateBrickRequestModel({
    required this.name,
    required this.color,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      'icon': icon,
    };
  }
}
