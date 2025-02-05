import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

String dateToJson(DateTime date) =>
    DateFormat("yyyy-MM-ddTHH:mm:ss").format(date);
DateTime dateFromJson(String date) =>
    DateFormat("yyyy-MM-ddTHH:mm:ss").parse(date);

String? nullableDateToJson(DateTime? date) =>
    date == null ? null : DateFormat("yyyy-MM-ddTHH:mm:ss").format(date);
DateTime? nullableDateFromJson(String? date) =>
    date == null ? null : DateFormat("yyyy-MM-ddTHH:mm:ss").parse(date);

abstract class BaseDatabaseModel {
  @JsonKey(
    toJson: dateToJson,
    fromJson: dateFromJson,
  )
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
