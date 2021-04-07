import 'package:socket_io/socket_io.dart';
import 'package:werewolf_server/entity/entity.dart';
import 'package:werewolf_server/socket/socket_constant.dart';
import 'package:werewolf_server/werewolf_server.dart';

import 'socket_manager_interface.dart';
import 'socket_room.dart';

class SocketManager extends SocketManagerInterface {
  final List<SocketRoom> _allRooms = [];
  final List<SocketRoom> _waitRooms = [];
  final List<SocketRoom> _doneRooms = [];
  final List<SocketRoom> _playingRooms = [];
  Server _io;

  SocketManager._();

  static SocketManager _instance;

  factory SocketManager() => _instance ??= SocketManager._();

  void init(Server io) {
    _io = io;
  }

  SocketRoom _getRoomByUserId(int id) {
    return _allRooms.firstWhere((room) {
      final _socket = room.members.firstWhere((socket) {
        final _user = socket.data['user'] as User;
        return _user?.id == id;
      }, orElse: () => null);
      return _socket != null;
    }, orElse: () => null);
  }

  void _addRoom(SocketRoom room) {
    _allRooms.add(room);
    if (room.state == SocketRoomState.wait)
      _waitRooms.add(room);
    else if (room.state == SocketRoomState.playing)
      _playingRooms.add(room);
    else if (room.state == SocketRoomState.done) _doneRooms.add(room);
  }

  void _removeRoom(SocketRoom room) {
    if (_allRooms.contains(room))
      _allRooms.remove(room);
    if (_waitRooms.contains(room))
      _waitRooms.remove(room);
    if (_playingRooms.contains(room))
      _playingRooms.remove(room);
    if (_doneRooms.contains(room))
      _doneRooms.remove(room);
  }

  @override
  void playerFindRoom(Socket socket, dynamic _data) {
    final Map<String, dynamic> data = AppConverter.parseToMap(_data);
    final User user = socket.data['user'] as User;
    final String type = data['type'] as String;
    final SocketRoom room = _waitRooms.firstWhere((_room) {
      return _room.languageCode == user.languageCode &&
          _room.countMember < SocketRoom.maxMember;
    },
        orElse: () => SocketRoom(
            state: SocketRoomState.wait,
            type: stringToEnum(type, SocketRoomType.values),
            members: [socket],
            languageCode: user.languageCode));
    print('room: ${room.toJson()}');
    socket.join(room.id);
    _addRoom(room);
    socket.emit(SocketConstant.emitInfoRoom, room.toJson());
    _io.to(room.id).emit(SocketConstant.emitMessageRoom,
        {'msg': 'Chào mừng ${user.fullName} đã tham gia phòng !'});
    print('Rooms wait: $_waitRooms');
    print('Rooms: $_allRooms');
  }

  @override
  void playerLeaveRoom(Socket socket, dynamic _data) {
    final Map<String, dynamic> data = AppConverter.parseToMap(_data);
    final user = socket.data['user'] as User;
    final room = _getRoomByUserId(user.id);
    if (room != null) {
      _io.to(room.id).emit(SocketConstant.emitMessageRoom,
          {'msg': '${user.fullName} đã rời phòng!'});
      socket.leave(room.id, (err) => print('Error leave room: $err'));
      _removeRoom(room);
    }
    print('Rooms wait: $_waitRooms');
    print('Rooms: $_allRooms');
  }

  @override
  void playerReady(Socket socket, dynamic _data) {
    final Map<String, dynamic> data = AppConverter.parseToMap(_data);
    final user = socket.data['user'] as User;
    final room = _getRoomByUserId(user.id);
    print('Rooms wait: $_waitRooms');
    print('Rooms: $_allRooms');
    if (room != null) {
      _io.to(room.id).emit(SocketConstant.emitMessageRoom,
          {'msg': '${user.fullName} đã sẵn sàng!'});
      socket.data.addEntries([const MapEntry('state', SocketUserState.ready)]);
      if (room.countMember >= SocketRoom.minMember) {
        _removeRoom(room);
        room.state = SocketRoomState.ready;
        _addRoom(room);
        _io.to(room.id).emit(SocketConstant.emitReadyRoom,
            {'msg': 'Phòng đã đã sẵn sàng!\nVán ma sói sẽ bắt đầu sau 10s!'});
        Future.delayed(const Duration(seconds: 10), () {
          _io.to(room.id).emit(SocketConstant.emitRolePlayer,
              {'msg': 'Vai trò của bạn là Dân làng!'});
        });
        print('Rooms wait: $_waitRooms');
        print('Rooms: $_allRooms');
      }
    }
  }
}
