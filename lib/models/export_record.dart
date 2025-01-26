import 'package:json_annotation/json_annotation.dart';
import 'package:stock_buddy/models/base_db_model.dart';

part 'export_record.g.dart';

@JsonSerializable()
class ExportRecord extends BaseDatabaseModel {
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
  @JsonKey(name: 'depot_id')
  final String depotId;
  @JsonKey(name: 'total_spent')
  final double totalValue;

  ExportRecord(
      this.exportDate,
      this.customerName,
      this.depotNumber,
      DateTime createdAt,
      String id,
      this.winLossAmount,
      this.winLossPercent,
      this.depotId,
      this.totalValue)
      : super(createdAt, id);

  factory ExportRecord.fromJson(Map<String, dynamic> json) =>
      _$ExportRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ExportRecordToJson(this);
}
