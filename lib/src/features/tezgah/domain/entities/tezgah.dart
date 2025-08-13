import 'package:equatable/equatable.dart';

class Tezgah extends Equatable {
  final String id; // API'de yoksa loomNo ile doldurulacak
  final String loomNo;
  final double efficiency;
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
  final double weaverEff;
  final String eventDuration;
  final double productedLength;
  final double totalLength;
  final String eventNameTR;
  final String opDuration;
  final bool holiday;
  final int status;
  final bool isSelected;

  const Tezgah({
    required this.id,
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
    this.isSelected = false,
  });

  Tezgah copyWith({
    String? id,
    String? loomNo,
    double? efficiency,
    String? operationName,
    String? operatorName,
    String? weaverName,
    int? eventId,
    int? loomSpeed,
    String? hallName,
    String? markName,
    String? modelName,
    String? groupName,
    String? className,
    String? warpName,
    String? variantNo,
    String? styleName,
    double? weaverEff,
    String? eventDuration,
    double? productedLength,
    double? totalLength,
    String? eventNameTR,
    String? opDuration,
    bool? holiday,
    int? status,
    bool? isSelected,
  }) {
    return Tezgah(
      id: id ?? this.id,
      loomNo: loomNo ?? this.loomNo,
      efficiency: efficiency ?? this.efficiency,
      operationName: operationName ?? this.operationName,
      operatorName: operatorName ?? this.operatorName,
      weaverName: weaverName ?? this.weaverName,
      eventId: eventId ?? this.eventId,
      loomSpeed: loomSpeed ?? this.loomSpeed,
      hallName: hallName ?? this.hallName,
      markName: markName ?? this.markName,
      modelName: modelName ?? this.modelName,
      groupName: groupName ?? this.groupName,
      className: className ?? this.className,
      warpName: warpName ?? this.warpName,
      variantNo: variantNo ?? this.variantNo,
      styleName: styleName ?? this.styleName,
      weaverEff: weaverEff ?? this.weaverEff,
      eventDuration: eventDuration ?? this.eventDuration,
      productedLength: productedLength ?? this.productedLength,
      totalLength: totalLength ?? this.totalLength,
      eventNameTR: eventNameTR ?? this.eventNameTR,
      opDuration: opDuration ?? this.opDuration,
      holiday: holiday ?? this.holiday,
      status: status ?? this.status,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [
        id,
        loomNo,
        efficiency,
        operationName,
        operatorName,
        weaverName,
        eventId,
        loomSpeed,
        hallName,
        markName,
        modelName,
        groupName,
        className,
        warpName,
        variantNo,
        styleName,
        weaverEff,
        eventDuration,
        productedLength,
        totalLength,
        eventNameTR,
        opDuration,
        holiday,
        status,
        isSelected,
      ];
}
