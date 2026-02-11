import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class WaiterProfileModel extends Equatable {
  final int id;
  final String? name;
  final String email;
  final String role;
  final String location;
  @JsonKey(name: 'profile_image')
  final String? profileImageUrl;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'orders_served_today')
  final int ordersServedToday;
  final String? phone;
  final String? address;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;

  const WaiterProfileModel({
    required this.id,
    this.name,
    required this.email,
    required this.role,
    required this.location,
    this.profileImageUrl,
    required this.isVerified,
    required this.ordersServedToday,
    this.phone,
    this.address,
    this.firstName,
    this.lastName,
  });

  factory WaiterProfileModel.fromJson(Map<String, dynamic> json) =>
      _$WaiterProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$WaiterProfileModelToJson(this);

  WaiterProfileModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? location,
    String? profileImageUrl,
    bool? isVerified,
    int? ordersServedToday,
    String? phone,
    String? address,
    String? firstName,
    String? lastName,
  }) {
    return WaiterProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      ordersServedToday: ordersServedToday ?? this.ordersServedToday,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    location,
    profileImageUrl,
    isVerified,
    ordersServedToday,
    phone,
    address,
    firstName,
    lastName,
  ];
}
