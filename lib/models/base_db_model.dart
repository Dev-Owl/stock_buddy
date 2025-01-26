import 'package:json_annotation/json_annotation.dart';

abstract class BaseDatabaseModel {
  final DateTime createdAt;
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(
    name: '_rev',
    includeIfNull: false,
  )
  String? rev;

  BaseDatabaseModel(this.createdAt, this.id, this.rev);
}
