import '../werewolf_server.dart';

abstract class EntityBase extends Serializable {
  int _id;

  EntityBase({int id}) {
    _id = id;
  }

  set id(int id) => _id;

  int get id => _id ?? DateTime.now().microsecondsSinceEpoch;

  Future insert();

  Future update();

  Future detete();
}
