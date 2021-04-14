import 'dart:async';
import 'package:werewolf_server/werewolf_server.dart';

import 'entity.dart';

class Language extends EntityBase {
  String name;
  String code;

  Language({this.name, this.code, int id}) : super(id: id);

  final DbCollection _db = AppDatabase.colLanguage;

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

  static List<Language> listFromJson(dynamic json) {
    List<Language> data = [];
    if (!(json is List) || json == null) return data;
    json.forEach((e) {
      data.add(Language.fromJson(e));
    });
    return data;
  }

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
        id: json['id'] as int,
        name: json['name'] as String,
        code: json['code'] as String);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "code": code};
  }

  @override
  List<Object> get props => throw UnimplementedError();
}
