import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/personnel.dart';

part 'personnel_dto.g.dart';

@JsonSerializable()
class PersonnelDto {
  @JsonKey(name: 'personnelID')
  final int personnelID;
  @JsonKey(name: 'personnelName')
  final String personnelName;

  const PersonnelDto({required this.personnelID, required this.personnelName});

  factory PersonnelDto.fromJson(Map<String, dynamic> json) =>
      _$PersonnelDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PersonnelDtoToJson(this);

  Personnel toDomain() => Personnel(id: personnelID, name: personnelName);
}
