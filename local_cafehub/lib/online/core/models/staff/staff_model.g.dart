// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffMember _$StaffMemberFromJson(Map<String, dynamic> json) => StaffMember(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      roleDisplay: json['role_display'] as String,
      isActive: json['is_active'] as bool,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$StaffMemberToJson(StaffMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'role': instance.role,
      'role_display': instance.roleDisplay,
      'is_active': instance.isActive,
      'phone': instance.phone,
      'address': instance.address,
    };

StaffListResponse _$StaffListResponseFromJson(Map<String, dynamic> json) =>
    StaffListResponse(
      success: json['success'] as bool,
      count: (json['count'] as num).toInt(),
      staff: (json['staff'] as List<dynamic>)
          .map((e) => StaffMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StaffListResponseToJson(StaffListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'staff': instance.staff,
    };

StaffInvitation _$StaffInvitationFromJson(Map<String, dynamic> json) =>
    StaffInvitation(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      roleDisplay: json['role_display'] as String,
      status: json['status'] as String,
      qrCodeUrl: json['qr_code_url'] as String?,
      createdAt: json['created_at'] as String,
      expiresAt: json['expires_at'] as String,
    );

Map<String, dynamic> _$StaffInvitationToJson(StaffInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': instance.role,
      'role_display': instance.roleDisplay,
      'status': instance.status,
      'qr_code_url': instance.qrCodeUrl,
      'created_at': instance.createdAt,
      'expires_at': instance.expiresAt,
    };

StaffInvitationResponse _$StaffInvitationResponseFromJson(
        Map<String, dynamic> json) =>
    StaffInvitationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      invite: StaffInvitation.fromJson(json['invite'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StaffInvitationResponseToJson(
        StaffInvitationResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'invite': instance.invite,
    };

StaffInvitationListResponse _$StaffInvitationListResponseFromJson(
        Map<String, dynamic> json) =>
    StaffInvitationListResponse(
      success: json['success'] as bool,
      count: (json['count'] as num).toInt(),
      invitations: (json['invites'] as List<dynamic>?)
              ?.map((e) => StaffInvitation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$StaffInvitationListResponseToJson(
        StaffInvitationListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'invites': instance.invitations,
    };

CreateStaffInvitationRequest _$CreateStaffInvitationRequestFromJson(
        Map<String, dynamic> json) =>
    CreateStaffInvitationRequest(
      email: json['email'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$CreateStaffInvitationRequestToJson(
        CreateStaffInvitationRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'role': instance.role,
    };

StaffStatusToggleRequest _$StaffStatusToggleRequestFromJson(
        Map<String, dynamic> json) =>
    StaffStatusToggleRequest(
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$StaffStatusToggleRequestToJson(
        StaffStatusToggleRequest instance) =>
    <String, dynamic>{
      'is_active': instance.isActive,
    };

StaffStatusToggleResponse _$StaffStatusToggleResponseFromJson(
        Map<String, dynamic> json) =>
    StaffStatusToggleResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      staff: StaffMember.fromJson(json['staff'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StaffStatusToggleResponseToJson(
        StaffStatusToggleResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'staff': instance.staff,
    };
