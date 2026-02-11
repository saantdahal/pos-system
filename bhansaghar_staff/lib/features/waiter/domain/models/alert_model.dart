import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'alert_model.g.dart';

@JsonSerializable()
class AlertModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final AlertType type;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'action_url')
  final String? actionUrl;

  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.actionUrl,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) =>
      _$AlertModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlertModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    createdAt,
    isRead,
    actionUrl,
  ];

  AlertModel copyWith({
    int? id,
    String? title,
    String? description,
    AlertType? type,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}

enum AlertType { table, order, kitchen, system }
