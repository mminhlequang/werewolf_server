import '../werewolf_server.dart';

abstract class EntityBase extends Equatable {
  int _id;

  EntityBase({int id}) {
    _id = id;
  }

  set id(int id) => _id = id;

  int get id => _id ?? DateTime.now().microsecondsSinceEpoch;

  Future view();

  Future insert();

  Future update();

  Future delete();

  EntityBase fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson();
}
