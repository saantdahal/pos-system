import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  final int id;
  final String email;
  final String username;
  final String role;
  @JsonKey(name: 'is_active')
  final bool isActive;

  UserInfo({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.isActive,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
