import 'package:json_annotation/json_annotation.dart';

part 'create_depot_item.g.dart';

@JsonSerializable()
class CreateDepotItem {
  @JsonKey(name: 'depot_id')
  final String depotId;
  final String isin;
  final List<String>? tags;

  CreateDepotItem(this.depotId, this.isin, {this.tags});
  factory CreateDepotItem.fromJson(Map<String, dynamic> json) =>
      _$CreateDepotItemFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDepotItemToJson(this);
}
