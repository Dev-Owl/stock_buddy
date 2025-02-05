import 'package:stock_buddy/models/base_db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deopt_item.g.dart';

@JsonSerializable()
class DepotItem extends BaseDatabaseModel {
  List<String>? tags;
  String isin;
  String? note;
  String name;
  String depotId;
  double lastTotalValue;
  double lastWinLoss;
  double lastWinLossPercent;
  bool active;
  double totalDividends;

  DepotItem({
    required this.isin,
    required this.name,
    required this.depotId,
    required this.lastTotalValue,
    required this.lastWinLoss,
    required this.lastWinLossPercent,
    required this.active,
    required this.totalDividends,
    this.tags,
    this.note,
    required String id,
    String? rev,
    required DateTime createdAt,
  }) : super(createdAt, id, rev);

  factory DepotItem.fromJson(Map<String, dynamic> json) =>
      _$DepotItemFromJson(json);

  Map<String, dynamic> toJson() => _$DepotItemToJson(this);
}
