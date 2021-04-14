import 'package:socket_io/socket_io.dart';
import 'package:werewolf_server/constants/constants.dart';
import 'package:werewolf_server/entity/entity.dart';
import 'package:werewolf_server/socket/socket_manager.dart';
import 'package:werewolf_server/socket/socket_room_interface.dart';
import 'package:werewolf_server/utils/converter.dart';
import 'package:werewolf_server/werewolf_server.dart';
import '../extensions/extensions.dart';

import 'socket_constant.dart';

enum SocketUserState { ready, prepare }

enum SocketRoomType { normal, rank }

enum SocketRoomState { wait, ready, playing, done }

class SocketRoom extends SocketRoomInterface {
  static const int maxMember = 16;
  static const int minMember = 12;
  static const int beforeStart = 10;

  final SocketManager _manager = SocketManager();

  SocketRoomType type;
  SocketRoomState state;
  List<Socket> members;
  String languageCode;
  String id;
  List<Role> roles;

  SocketRoom(
      {this.members,
      this.type,
      this.languageCode = AppValues.defaultLanguageCode,
      this.state = SocketRoomState.wait,
      String id}) {
    this.id = id ?? DateTime.now().microsecondsSinceEpoch.toString();
  }

  int get countMember => members?.length ?? 0;

  bool get allReady {
    bool status = true;
    for (Socket socket in members) {
      if (socket.getState() != SocketUserState.ready) status = false;
      break;
    }
    return status;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": AppConverter.enumToString(type),
      "state": AppConverter.enumToString(state),
      "members": members.map((e) => (e.data['user'] as User).toJson()).toList(),
      "languageCode": languageCode
    };
  }

  void getRoles() async {
    if (countMember < minMember) return;
    final countVillager = (countMember / 2).floor();
    final countOther = countMember <= 14 ? 2 : 3;
    final countWolf = countMember - countVillager - countOther;
    final villagers = (await AppDatabase.colRole
            .find(where
                .eq('languageId', 1)
                .eq('sectarians', [1]).limit(countVillager))
            .toList())
        .toRoles;

    final wolfs = (await AppDatabase.colRole
            .find(where
                .eq('languageId', 1)
                .eq('sectarians', [2]).limit(countWolf))
            .toList())
        .toRoles;

    final others = (await AppDatabase.colRole
            .find(where
                .eq('languageId', 1)
                .eq('sectarians', [3]).limit(countOther))
            .toList())
        .toRoles;

    roles = villagers + wolfs + others;
  }

  @override
  void join(Socket socket) {
    if (!members.contains(socket)) members.add(socket);

    ////Test
    for (int i = 0; i < SocketRoom.minMember; i++) {
      socket.ready();
      members.add(socket);
    }
    print('countMember: $countMember - allReady: $allReady');
    /////
    socket.join(id);
    socket.emit(SocketConstant.emitInfoRoom, toJson());
    _manager.io.to(id).emit(SocketConstant.emitMessageRoom, {
      'msg': AppMessages.getMessage('room_welcome',
          values: [socket.user?.fullName])
    });
  }

  @override
  void leave(Socket socket) {
    if (members.contains(socket)) {
      members.remove(socket);
      if (countMember == 0) _manager.removeRoom(this);
      _manager.io.to(id).emit(SocketConstant.emitMessageRoom, {
        'msg': AppMessages.getMessage('room_leave',
            values: [socket.user?.fullName])
      });
      socket.leave(id, (x) => print('Leave room callback: $x'));
    }
  }

  @override
  void ready(Socket socket) async {
    if (!members.contains(socket)) return;
    _manager.io.to(id).emit(SocketConstant.emitMessageRoom, {
      'msg': AppMessages.getMessage('room_user_ready',
          values: [socket.user?.fullName])
    });
    socket.ready();
    if (countMember >= SocketRoom.minMember && allReady) {
      _manager.removeRoom(this);
      state = SocketRoomState.ready;
      _manager.addRoom(this);

      //Random role for all player
      await getRoles();

      _manager.io.to(id).emit(SocketConstant.emitReadyRoom, {
        'msg': AppMessages.getMessage('room_ready', values: ['$beforeStart'])
      });

      Future.delayed(const Duration(seconds: beforeStart), () {
        _manager.io.to(id).emit(SocketConstant.emitRolePlayer,
            {'msg': 'Vai trò của bạn là Dân làng!'});
      });
    }
  }
}
