import 'package:socket_io/socket_io.dart';
import 'package:werewolf_server/constants/constants.dart';
import 'package:werewolf_server/entity/entity.dart';
import 'package:werewolf_server/socket/socket_manager.dart';
import 'package:werewolf_server/socket/socket_room_interface.dart';
import 'package:werewolf_server/utils/converter.dart';
import '../extensions/extensions.dart';

import 'socket_constant.dart';

enum SocketUserState { ready, prepare }

enum SocketRoomType { normal, rank }

enum SocketRoomState { wait, ready, playing, done }

class SocketRoom extends SocketRoomInterface {
  static const int maxMember = 16;
  static const int minMember = 12;
  static const int beforeStart = 15;

  final SocketManager _manager = SocketManager();

  SocketRoomType type;
  SocketRoomState state;
  List<Socket> members;
  String languageCode;
  String id;

  SocketRoom(
      {this.members,
      this.type,
      this.languageCode = AppValues.defaultLanguageCode,
      this.state = SocketRoomState.wait,
      String id}) {
    this.id = id ?? DateTime.now().microsecondsSinceEpoch.toString();
  }

  int get countMember => members?.length ?? 0;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": AppConverter.enumToString(type),
      "state": AppConverter.enumToString(state),
      "members": members.map((e) => (e.data['user'] as User).toJson()).toList(),
      "languageCode": languageCode
    };
  }

  @override
  void join(Socket socket) {
    if (!members.contains(socket))
      members.add(socket);
    socket.join(id);
    socket.emit(SocketConstant.emitInfoRoom, toJson());
    _manager.io.to(id).emit(SocketConstant.emitMessageRoom, {
      'msg': AppMessages.getMessage('room_welcome',
          values: [socket.getUser()?.fullName])
    });
  }

  @override
  void leave(Socket socket) {
    print('Leave room callback: :))');
    if (members.contains(socket)) {
      members.remove(socket);
      if (countMember == 0)
        _manager.removeRoom(this);
      _manager.io.to(id).emit(SocketConstant.emitMessageRoom, {
        'msg': AppMessages.getMessage('room_leave',
            values: [socket.getUser()?.fullName])
      });
      socket.leave(id, (x) => print('Leave room callback: $x'));
    }
  }

  @override
  void ready(Socket socket) {
    if (!members.contains(socket))
      return;
    _manager.io.to(id).emit(SocketConstant.emitMessageRoom, {
      'msg': AppMessages.getMessage('room_user_ready',
          values: [socket.getUser()?.fullName])
    });
    socket.data.addEntries([const MapEntry('state', SocketUserState.ready)]);
    if (countMember >= SocketRoom.minMember) {
      _manager.removeRoom(this);
      state = SocketRoomState.ready;
      _manager.addRoom(this);
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
