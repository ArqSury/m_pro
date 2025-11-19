import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  final String? message;
  final Data? data;

  UserModel({this.message, this.data});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  final int? id;
  final String? name;
  final String? email;
  final dynamic emailVerifiedAt;

  // Backend sometimes does NOT send these fields, so MUST be optional
  final String? profilePhoto;
  final String? profilePhotoUrl;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Data({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.profilePhoto,
    this.profilePhotoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],

    // Backend may NOT send these (null OK)
    profilePhoto: json["profile_photo"],
    profilePhotoUrl: json["profile_photo_url"],

    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "profile_photo": profilePhoto,
    "profile_photo_url": profilePhotoUrl,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
