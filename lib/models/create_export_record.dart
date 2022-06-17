import 'package:json_annotation/json_annotation.dart';

part 'create_export_record.g.dart';

@JsonSerializable()
class CreateExportRecord {
  @JsonKey(name: 'export_time')
  final DateTime exportDate;
  @JsonKey(name: 'name')
  final String customerName;
  @JsonKey(name: 'number')
  final String depotNumber;
  @JsonKey(name: 'win_loss_amount')
  final double winLossAmount;
  @JsonKey(name: 'win_loss_percent')
  final double winLossPercent;

  CreateExportRecord(
    this.exportDate,
    this.customerName,
    this.depotNumber,
    this.winLossAmount,
    this.winLossPercent,
  );
  factory CreateExportRecord.fromJson(Map<String, dynamic> json) =>
      _$CreateExportRecordFromJson(json);

  Map<String, dynamic> toJson() => _$CreateExportRecordToJson(this);
}
