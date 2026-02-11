import 'package:json_annotation/json_annotation.dart';

part 'category_request.g.dart';

@JsonSerializable()
class CategoryRequest {
  final String name;

  CategoryRequest({required this.name});

  factory CategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$CategoryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryRequestToJson(this);

  @override
  String toString() => 'CategoryRequest(name: $name)';
}
