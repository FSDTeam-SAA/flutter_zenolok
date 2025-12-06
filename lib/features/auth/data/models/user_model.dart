class UserModel {
  final String id;
  final String name;
  final String email;
  final String? password;
  final String username;
  final String role;
  final String? phone;
  final String? stripeAccountId;
  final bool isStripeOnboarded;
  final String? address;
  final int fine;
  final String refreshToken;
  final bool tredingProfileComplete;
  final String uniqueId;
  final String createdAt;
  final String updatedAt;
  final int v;
  final VerificationInfo? verificationInfo;
  final UserRating? userRating;
  final TrendingProfile? trendingProfile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.username,
    required this.role,
    this.phone,
    this.stripeAccountId,
    required this.isStripeOnboarded,
    this.address,
    required this.fine,
    required this.refreshToken,
    required this.tredingProfileComplete,
    required this.uniqueId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.verificationInfo,
    this.userRating,
    this.trendingProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'],
      stripeAccountId: json['stripeAccountId'],
      isStripeOnboarded: json['isStripeOnboarded'] ?? false,
      address: json['address'],
      fine: json['fine'] ?? 0,
      refreshToken: json['refreshToken'] ?? '',
      tredingProfileComplete: json['treding_profile_Complete'] ?? false,
      uniqueId: json['uniqueId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
      verificationInfo: json['verificationInfo'] != null
          ? VerificationInfo.fromJson(json['verificationInfo'])
          : null,
      userRating: json['userRating'] != null
          ? UserRating.fromJson(json['userRating'])
          : null,
      trendingProfile: json['treding_profile'] != null
          ? TrendingProfile.fromJson(json['treding_profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'username': username,
      'role': role,
      'phone': phone,
      'stripeAccountId': stripeAccountId,
      'isStripeOnboarded': isStripeOnboarded,
      'address': address,
      'fine': fine,
      'refreshToken': refreshToken,
      'treding_profile_Complete': tredingProfileComplete,
      'uniqueId': uniqueId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'verificationInfo': verificationInfo?.toJson(),
      'userRating': userRating?.toJson(),
      'treding_profile': trendingProfile?.toJson(),
    };
  }
}

class VerificationInfo {
  final bool verified;
  final String? token;

  VerificationInfo({required this.verified, this.token});

  factory VerificationInfo.fromJson(Map<String, dynamic> json) {
    return VerificationInfo(
      verified: json['verified'] ?? false,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verified': verified,
      'token': token,
    };
  }
}

class UserRating {
  final RatingDetail? competence;
  final RatingDetail? punctuality;
  final RatingDetail? behavior;

  UserRating({this.competence, this.punctuality, this.behavior});

  factory UserRating.fromJson(Map<String, dynamic> json) {
    return UserRating(
      competence: json['competence'] != null
          ? RatingDetail.fromJson(json['competence'])
          : null,
      punctuality: json['punctuality'] != null
          ? RatingDetail.fromJson(json['punctuality'])
          : null,
      behavior: json['behavior'] != null
          ? RatingDetail.fromJson(json['behavior'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competence': competence?.toJson(),
      'punctuality': punctuality?.toJson(),
      'behavior': behavior?.toJson(),
    };
  }
}

class RatingDetail {
  final int star;
  final String? comment;

  RatingDetail({required this.star, this.comment});

  factory RatingDetail.fromJson(Map<String, dynamic> json) {
    return RatingDetail(
      star: json['star'] ?? 0,
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'star': star,
      'comment': comment,
    };
  }
}

class TrendingProfile {
  final List<dynamic> prefferedLearning;

  TrendingProfile({required this.prefferedLearning});

  factory TrendingProfile.fromJson(Map<String, dynamic> json) {
    return TrendingProfile(
      prefferedLearning: json['preffered_learning'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preffered_learning': prefferedLearning,
    };
  }
}