import 'package:json_annotation/json_annotation.dart';

abstract class BaseDatabaseModel {
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final String id;
  @JsonKey(name: 'owner_id')
  final String ownerId;

  BaseDatabaseModel(this.createdAt, this.id, this.ownerId);
}
