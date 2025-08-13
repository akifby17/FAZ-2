import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/operation.dart';

part 'operation_dto.g.dart';

@JsonSerializable()
class OperationDto {
  final String code;
  final String name;

  const OperationDto({required this.code, required this.name});

  factory OperationDto.fromJson(Map<String, dynamic> json) =>
      _$OperationDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OperationDtoToJson(this);

  Operation toDomain() => Operation(code: code, name: name);
}
