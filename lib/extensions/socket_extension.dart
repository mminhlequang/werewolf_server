import 'package:socket_io/socket_io.dart';
import 'package:werewolf_server/entity/entity.dart';
import 'package:werewolf_server/socket/socket_room.dart';

extension DataSocket on Socket {
  set role(Role role) {
    data.addEntries([MapEntry('role', role)]);
  }

  Role get role => data['role'] as Role;

  set state(SocketUserState state) {
    data.addEntries([MapEntry('state', state)]);
  }

  SocketUserState get state => data['state'] as SocketUserState;

  set user(User user) {
    data.addEntries([MapEntry('user', user)]);
  }

  User get user => data['user'] as User;
}
