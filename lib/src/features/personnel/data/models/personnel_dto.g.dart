// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personnel_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonnelDto _$PersonnelDtoFromJson(Map<String, dynamic> json) => PersonnelDto(
      personnelID: (json['personnelID'] as num).toInt(),
      personnelName: json['personnelName'] as String,
    );

Map<String, dynamic> _$PersonnelDtoToJson(PersonnelDto instance) =>
    <String, dynamic>{
      'personnelID': instance.personnelID,
      'personnelName': instance.personnelName,
    };
