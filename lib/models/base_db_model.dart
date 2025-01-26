import 'package:json_annotation/json_annotation.dart';

abstract class BaseDatabaseModel {
  final DateTime createdAt;
  @JsonKey(name: '_id')
  final String id;

  BaseDatabaseModel(this.createdAt, this.id);
}
