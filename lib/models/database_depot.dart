import 'package:stock_buddy/models/base_db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'database_depot.g.dart';

@JsonSerializable()
class DataDepot extends BaseDatabaseModel {
  static toNull(_) => null;

  String? notes;
  String name;
  String number;
  int totalExports; //total amount of exports
  double totalGainLoss; //from last export sum
  double totalGainLossPercent;
  @JsonKey(
    toJson: nullableDateToJson,
    fromJson: nullableDateFromJson,
  )
  DateTime? lastExportTime;

  DataDepot(
    this.name,
    this.number,
    DateTime createdAt,
    String id,
    String? rev,
    this.totalExports,
    this.totalGainLoss,
    this.totalGainLossPercent,
    this.notes,
    this.lastExportTime,
  ) : super(createdAt, id, rev);

  factory DataDepot.fromJson(Map<String, dynamic> json) =>
      _$DataDepotFromJson(json);

  Map<String, dynamic> toJson() => _$DataDepotToJson(this);
}
