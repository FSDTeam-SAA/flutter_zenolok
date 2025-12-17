class UserModel {
  final String id;
  final String email;
  final String username;
  final String role;
  final AvatarModel avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'] != null
          ? AvatarModel.fromJson(json['avatar'])
          : AvatarModel(publicId: '', url: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'username': username,
      'role': role,
      'avatar': avatar.toJson(),
    };
  }
}

class AvatarModel {
  final String publicId;
  final String url;

  AvatarModel({
    required this.publicId,
    required this.url,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'url': url,
    };
  }
}