import 'package:stock_buddy/models/base_db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'database_depot.g.dart';

@JsonSerializable()
class DataDepot extends BaseDatabaseModel {
  final String name;
  final String number;
  final int totalExports; //total amount of exports
  final double totalGainLoss; //from last export sum

  DataDepot(
    this.name,
    this.number,
    DateTime createdAt,
    String id,
    String ownerId,
    this.totalExports,
    this.totalGainLoss,
  ) : super(createdAt, id, ownerId);

  factory DataDepot.fromJson(Map<String, dynamic> json) =>
      _$DataDepotFromJson(json);

  Map<String, dynamic> toJson() => _$DataDepotToJson(this);
}
