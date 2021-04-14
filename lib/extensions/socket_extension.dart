import 'package:socket_io/socket_io.dart';
import 'package:werewolf_server/entity/entity.dart';
import 'package:werewolf_server/socket/socket_room.dart';

extension DataSocket on Socket {
  set role(Role role) {
    data.addEntries([MapEntry('role', role)]);
  }

  Role get role => data['role'] as Role;

  void ready() {
    data.addEntries([const MapEntry('state', SocketUserState.ready)]);
  }

  SocketUserState getState() {
    if (data == null || data.isEmpty || data['state'] == null)
      return SocketUserState.prepare;
    return data['state'] as SocketUserState;
  }

  set user(User user) {
    data.addEntries([MapEntry('user', user)]);
  }

  User get user => data['user'] as User;

  void addEntryData(MapEntry entry) {
    data.addEntries([entry]);
  }
}
