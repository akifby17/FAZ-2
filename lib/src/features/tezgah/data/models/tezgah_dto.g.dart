// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tezgah_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TezgahDto _$TezgahDtoFromJson(Map<String, dynamic> json) => TezgahDto(
      loomNo: json['loomNo'] as String,
      efficiency: json['efficiency'] as num,
      operationName: json['operationName'] as String,
      operatorName: json['operatorName'] as String,
      weaverName: json['weaverName'] as String,
      eventId: (json['eventId'] as num).toInt(),
      loomSpeed: (json['loomSpeed'] as num).toInt(),
      hallName: json['hallName'] as String,
      markName: json['markName'] as String,
      modelName: json['modelName'] as String,
      groupName: json['groupName'] as String,
      className: json['className'] as String,
      warpName: json['warpName'] as String,
      variantNo: json['variantNo'] as String,
      styleName: json['styleName'] as String,
      weaverEff: json['weaverEff'] as num,
      eventDuration: json['eventDuration'] as String,
      productedLength: json['productedLength'] as num,
      totalLength: json['totalLength'] as num,
      eventNameTR: json['eventNameTR'] as String,
      opDuration: json['opDuration'] as String,
      holiday: json['holiday'] as bool,
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$TezgahDtoToJson(TezgahDto instance) => <String, dynamic>{
      'loomNo': instance.loomNo,
      'efficiency': instance.efficiency,
      'operationName': instance.operationName,
      'operatorName': instance.operatorName,
      'weaverName': instance.weaverName,
      'eventId': instance.eventId,
      'loomSpeed': instance.loomSpeed,
      'hallName': instance.hallName,
      'markName': instance.markName,
      'modelName': instance.modelName,
      'groupName': instance.groupName,
      'className': instance.className,
      'warpName': instance.warpName,
      'variantNo': instance.variantNo,
      'styleName': instance.styleName,
      'weaverEff': instance.weaverEff,
      'eventDuration': instance.eventDuration,
      'productedLength': instance.productedLength,
      'totalLength': instance.totalLength,
      'eventNameTR': instance.eventNameTR,
      'opDuration': instance.opDuration,
      'holiday': instance.holiday,
      'status': instance.status,
    };
