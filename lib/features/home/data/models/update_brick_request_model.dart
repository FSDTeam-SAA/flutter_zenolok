class UpdateBrickRequestModel {
  final String? name;
  final String? color; // hex "#RRGGBB"
  final String? icon;

  UpdateBrickRequestModel({this.name, this.color, this.icon});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    if (name != null) map['name'] = name;
    if (color != null) map['color'] = color;
    if (icon != null) map['icon'] = icon;
    return map;
  }
}
