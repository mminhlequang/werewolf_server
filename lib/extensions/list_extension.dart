import 'package:werewolf_server/entity/entity.dart';

extension EntityList on List {
  List get toRoles => Role.listFromJson(this);
}
