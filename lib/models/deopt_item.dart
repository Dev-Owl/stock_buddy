import 'package:stock_buddy/models/base_db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deopt_item.g.dart';

@JsonSerializable()
class DepotItem extends BaseDatabaseModel {
  final List<String>? tags;
  final String isin;
  final String? note;
  @JsonKey(name: 'depot_id')
  final String depotId;

  factory DepotItem.fromJson(Map<String, dynamic> json) =>
      _$DepotItemFromJson(json);

  DepotItem(
    DateTime createdAt,
    String id,
    String ownerId,
    this.tags,
    this.isin,
    this.depotId,
    this.note,
  ) : super(createdAt, id, ownerId);

  Map<String, dynamic> toJson() => _$DepotItemToJson(this);
}
