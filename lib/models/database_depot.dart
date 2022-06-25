import 'package:stock_buddy/models/base_db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'database_depot.g.dart';

@JsonSerializable()
class DataDepot extends BaseDatabaseModel {
  static toNull(_) => null;

  final String? notes;
  final String name;
  final String number;
  @JsonKey(
    toJson: toNull,
    includeIfNull: false,
    defaultValue: 0,
    name: 'totalexports',
  )
  final int totalExports; //total amount of exports
  @JsonKey(
    toJson: toNull,
    includeIfNull: false,
    defaultValue: 0,
    name: 'totalgainloss',
  )
  final double totalGainLoss; //from last export sum

  @JsonKey(
    toJson: toNull,
    includeIfNull: false,
    defaultValue: 0,
    name: 'totalgainlosspercent',
  )
  final double totalGainLossPercent;

  DataDepot(
    this.name,
    this.number,
    DateTime createdAt,
    String id,
    String ownerId,
    this.totalExports,
    this.totalGainLoss,
    this.totalGainLossPercent,
    this.notes,
  ) : super(createdAt, id, ownerId);

  DataDepot.forInsert(this.name, this.number,
      {this.totalExports = 0,
      this.totalGainLoss = 0,
      this.totalGainLossPercent = 0,
      this.notes})
      : super(DateTime.now(), '', '');

  factory DataDepot.fromJson(Map<String, dynamic> json) =>
      _$DataDepotFromJson(json);

  Map<String, dynamic> toJson() => _$DataDepotToJson(this);
}
