import 'package:json_annotation/json_annotation.dart';
import 'package:stock_buddy/models/base_db_model.dart';
import 'package:stock_buddy/models/export_line_item.dart';

part 'export_record.g.dart';

@JsonSerializable()
class ExportRecord extends BaseDatabaseModel {
  DateTime exportTime;
  String name;
  String number;
  double winLossAmount;
  double winLossPercent;
  String depotId;
  double totalSpent;

  List<ExportLineItem> lineItems = [];

  ExportRecord(
    this.exportTime,
    this.name,
    this.number,
    DateTime createdAt,
    String id,
    this.winLossAmount,
    this.winLossPercent,
    this.depotId,
    String rev,
    this.totalSpent,
    this.lineItems,
  ) : super(
          createdAt,
          id,
          rev,
        );

  factory ExportRecord.fromJson(Map<String, dynamic> json) =>
      _$ExportRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ExportRecordToJson(this);
}
