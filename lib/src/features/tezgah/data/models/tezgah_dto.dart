import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/tezgah.dart';

part 'tezgah_dto.g.dart';

@JsonSerializable()
class TezgahDto {
  final String loomNo;
  final num efficiency;
  final String operationName;
  final String operatorName;
  final String weaverName;
  final int eventId;
  final int loomSpeed;
  final String hallName;
  final String markName;
  final String modelName;
  final String groupName;
  final String className;
  final String warpName;
  final String variantNo;
  final String styleName;
  final num weaverEff;
  final String eventDuration;
  final num productedLength;
  final num totalLength;
  final String eventNameTR;
  final String opDuration;
  final bool holiday;
  final int status;

  const TezgahDto({
    required this.loomNo,
    required this.efficiency,
    required this.operationName,
    required this.operatorName,
    required this.weaverName,
    required this.eventId,
    required this.loomSpeed,
    required this.hallName,
    required this.markName,
    required this.modelName,
    required this.groupName,
    required this.className,
    required this.warpName,
    required this.variantNo,
    required this.styleName,
    required this.weaverEff,
    required this.eventDuration,
    required this.productedLength,
    required this.totalLength,
    required this.eventNameTR,
    required this.opDuration,
    required this.holiday,
    required this.status,
  });

  factory TezgahDto.fromJson(Map<String, dynamic> json) =>
      _$TezgahDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TezgahDtoToJson(this);

  Tezgah toDomain() => Tezgah(
        id: loomNo,
        loomNo: loomNo,
        efficiency: efficiency.toDouble(),
        operationName: operationName,
        operatorName: operatorName,
        weaverName: weaverName,
        eventId: eventId,
        loomSpeed: loomSpeed,
        hallName: hallName,
        markName: markName,
        modelName: modelName,
        groupName: groupName,
        className: className,
        warpName: warpName,
        variantNo: variantNo,
        styleName: styleName,
        weaverEff: weaverEff.toDouble(),
        eventDuration: eventDuration,
        productedLength: productedLength.toDouble(),
        totalLength: totalLength.toDouble(),
        eventNameTR: eventNameTR,
        opDuration: opDuration,
        holiday: holiday,
        status: status,
      );
}
