import 'package:json_annotation/json_annotation.dart';
import 'package:stock_buddy/models/base_db_model.dart';

part 'dividend_item.g.dart';

@JsonSerializable()
class DividendItem extends BaseDatabaseModel {
  @JsonKey(name: 'depot_id')
  final String depotId;
  @JsonKey(name: 'depot_item_id')
  final String depotItemId;
  final double amount;
  @JsonKey(name: 'booked_at')
  final DateTime bookedAt;

  DividendItem(super.createdAt, super.id, this.depotId, this.depotItemId,
      this.amount, this.bookedAt);

  factory DividendItem.fromJson(Map<String, dynamic> json) =>
      _$DividendItemFromJson(json);

  Map<String, dynamic> toJson() => _$DividendItemToJson(this);
}
