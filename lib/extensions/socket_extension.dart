import 'package:socket_io/socket_io.dart';
import 'package:werewolf_server/entity/entity.dart';
import 'package:werewolf_server/socket/socket_room.dart';

extension DataSocket on Socket {
  SocketUserState getState() {
    if (data == null || data.isEmpty || data['state'] == null)
      return SocketUserState.prepare;
    return data['state'] as SocketUserState;
  }

  User getUser() {
    if (data == null || data.isEmpty || data['user'] == null)
      return null;
    return data['user'] as User;
  }

  void addEntryData(MapEntry entry){
    data.addEntries([entry]);
  }
}
