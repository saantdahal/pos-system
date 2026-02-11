import 'package:json_annotation/json_annotation.dart';

part 'staff_model.g.dart';

@JsonSerializable()
class StaffMember {
  final int id;
  final String username;
  final String email;
  @JsonKey(name: 'role')
  final String role;
  @JsonKey(name: 'role_display')
  final String roleDisplay;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final String? phone;
  final String? address;

  StaffMember({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.roleDisplay,
    required this.isActive,
    this.phone,
    this.address,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) =>
      _$StaffMemberFromJson(json);

  Map<String, dynamic> toJson() => _$StaffMemberToJson(this);

  String get displayName => username;
  String get statusText => isActive ? 'Active' : 'Inactive';
  String get roleIcon => role == 'kitchen' ? '👨‍🍳' : '🧑‍💼';
}

@JsonSerializable()
class StaffListResponse {
  final bool success;
  final int count;
  final List<StaffMember> staff;

  StaffListResponse({
    required this.success,
    required this.count,
    required this.staff,
  });

  factory StaffListResponse.fromJson(Map<String, dynamic> json) =>
      _$StaffListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StaffListResponseToJson(this);
}

@JsonSerializable()
class StaffInvitation {
  final String id;
  final String email;
  final String role;
  @JsonKey(name: 'role_display')
  final String roleDisplay;
  final String status;
  @JsonKey(name: 'qr_code_url')
  final String? qrCodeUrl;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'expires_at')
  final String expiresAt;

  StaffInvitation({
    required this.id,
    required this.email,
    required this.role,
    required this.roleDisplay,
    required this.status,
    this.qrCodeUrl,
    required this.createdAt,
    required this.expiresAt,
  });

  factory StaffInvitation.fromJson(Map<String, dynamic> json) =>
      _$StaffInvitationFromJson(json);

  Map<String, dynamic> toJson() => _$StaffInvitationToJson(this);

  bool get isPending => status == 'pending';
  bool get isClaimed => status == 'claimed';
  bool get isExpired => status == 'expired';
}

@JsonSerializable()
class StaffInvitationResponse {
  final bool success;
  final String message;
  final StaffInvitation invite;

  StaffInvitationResponse({
    required this.success,
    required this.message,
    required this.invite,
  });

  factory StaffInvitationResponse.fromJson(Map<String, dynamic> json) =>
      _$StaffInvitationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StaffInvitationResponseToJson(this);
}

@JsonSerializable()
class StaffInvitationListResponse {
  final bool success;
  final int count;
  @JsonKey(name: 'invites', defaultValue: [])
  final List<StaffInvitation> invitations;

  StaffInvitationListResponse({
    required this.success,
    required this.count,
    required this.invitations,
  });

  factory StaffInvitationListResponse.fromJson(Map<String, dynamic> json) =>
      _$StaffInvitationListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StaffInvitationListResponseToJson(this);
}

@JsonSerializable()
class CreateStaffInvitationRequest {
  final String email;
  final String role;

  CreateStaffInvitationRequest({required this.email, required this.role});

  factory CreateStaffInvitationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateStaffInvitationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateStaffInvitationRequestToJson(this);
}

@JsonSerializable()
class StaffStatusToggleRequest {
  @JsonKey(name: 'is_active')
  final bool isActive;

  StaffStatusToggleRequest({required this.isActive});

  factory StaffStatusToggleRequest.fromJson(Map<String, dynamic> json) =>
      _$StaffStatusToggleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$StaffStatusToggleRequestToJson(this);
}

@JsonSerializable()
class StaffStatusToggleResponse {
  final bool success;
  final String message;
  final StaffMember staff;

  StaffStatusToggleResponse({
    required this.success,
    required this.message,
    required this.staff,
  });

  factory StaffStatusToggleResponse.fromJson(Map<String, dynamic> json) =>
      _$StaffStatusToggleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StaffStatusToggleResponseToJson(this);
}
