import 'package:stock_buddy/models/base_db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'database_depot.g.dart';

@JsonSerializable()
class DataDepot extends BaseDatabaseModel {
  static toNull(_) => null;

  final String? notes;
  final String name;
  final String number;
  final int totalExports; //total amount of exports
  final double totalGainLoss; //from last export sum
  final double totalGainLossPercent;
  final DateTime? lastExportTime;

  DataDepot(
    this.name,
    this.number,
    DateTime createdAt,
    String id,
    this.totalExports,
    this.totalGainLoss,
    this.totalGainLossPercent,
    this.notes,
    this.lastExportTime,
  ) : super(createdAt, id);

  factory DataDepot.fromJson(Map<String, dynamic> json) =>
      _$DataDepotFromJson(json);

  Map<String, dynamic> toJson() => _$DataDepotToJson(this);
}
