import 'dart:async';

import 'package:werewolf_server/werewolf_server.dart';

import 'entity.dart';

enum SectarianType { farmer, wolf, solo }

class Sectarian extends EntityBase {
  String name;
  String description;
  String icon;
  int languageId;

  Sectarian({this.name, this.description, this.icon, this.languageId, int id})
      : super(id: id);

  final DbCollection _db = AppDatabase.colSectarian;

  @override
  Future view() async {}

  @override
  Future insert() {
    return _db.insert(toJson());
  }

  @override
  Future update() async {
    final data = await _db.findOne({"id": id});
    toJson().forEach((key, value) {
      if (value != null) {
        data.update(key, (_) => value);
      }
    });
    return _db.update({"id": id}, data);
  }

  @override
  Future delete() {
    return _db.remove(where.eq('id', id));
  }

  static List<Sectarian> listFromJson(dynamic json) {
    List<Sectarian> data = [];
    if (!(json is List) || json == null) return data;
    json.forEach((e) {
      data.add(Sectarian.fromJson(e));
    });
    return data;
  }

  factory Sectarian.fromJson(Map<String, dynamic> json) {
    return Sectarian(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        languageId: json['languageId'] as int);
  }

  @override
  List<Object> get props => throw UnimplementedError();

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "icon": icon,
      "languageId": languageId
    };
  }
}
