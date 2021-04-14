import 'package:werewolf_server/werewolf_server.dart';

import 'entity.dart';

enum RoleType { classic, modern }

class Role extends EntityBase {
  String name;
  String description;
  String smallIcon;
  String icon;
  String actionIcon;
  int languageId;
  List<int> sectarians;
  RoleType type;

  Role(
      {this.name,
      this.description,
      this.smallIcon,
      this.icon,
      this.actionIcon,
      this.languageId,
      this.sectarians,
      this.type,
      int id})
      : super(id: id);

  final DbCollection _db = AppDatabase.colRole;

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

  static List<Role> listFromJson(dynamic json) {
    List<Role> data = [];
    if (!(json is List) || json == null) return data;
    json.forEach((e) {
      data.add(Role.fromJson(e));
    });
    return data;
  }

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        smallIcon: json['smallIcon'] as String,
        actionIcon: json['actionIcon'] as String,
        languageId: json['languageId'] as int,
        sectarians: json['sectarians'] as List<int>,
        type: AppConverter.stringToEnum<RoleType>(
            json['type'] as String, RoleType.values));
  }

  @override
  List<Object> get props => throw UnimplementedError();

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "icon": icon,
      "smallIcon": smallIcon,
      "actionIcon": actionIcon,
      "languageId": languageId,
      "sectarians": sectarians,
      "type": AppConverter.enumToString(type)
    };
  }
}
