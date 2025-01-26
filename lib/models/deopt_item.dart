import 'package:stock_buddy/models/base_db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deopt_item.g.dart';

@JsonSerializable()
class DepotItem extends BaseDatabaseModel {
  final List<String>? tags;
  final String isin;
  final String? note;
  final String name;
  @JsonKey(name: 'depot_id')
  final String depotId;
  @JsonKey(name: 'last_total_value')
  final double lastTotalValue;
  @JsonKey(name: 'last_win_loss')
  final double lastWinLoss;
  @JsonKey(name: 'last_win_loss_percent')
  final double lastWinLossPrecent;
  final bool active;

  factory DepotItem.fromJson(Map<String, dynamic> json) =>
      _$DepotItemFromJson(json);

  DepotItem(
    super.createdAt,
    super.id,
    super.rev,
    this.tags,
    this.isin,
    this.depotId,
    this.note,
    this.name,
    this.lastTotalValue,
    this.lastWinLoss,
    this.lastWinLossPrecent,
    this.active,
  );

  Map<String, dynamic> toJson() => _$DepotItemToJson(this);
}
