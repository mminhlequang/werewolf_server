import 'package:socket_io/socket_io.dart';
import 'package:werewolf_server/entity/entity.dart';
import 'package:werewolf_server/werewolf_server.dart';

import 'socket_manager_interface.dart';
import 'socket_room.dart';

class SocketManager extends SocketManagerInterface {
  final List<SocketRoom> _allRooms = [];
  final List<SocketRoom> _waitRooms = [];
  final List<SocketRoom> _readyRooms = [];
  final List<SocketRoom> _doneRooms = [];
  final List<SocketRoom> _playingRooms = [];
  Server _io;

  SocketManager._();

  static SocketManager _instance;

  factory SocketManager() => _instance ??= SocketManager._();

  Server get io => _io;

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

  void addRoom(SocketRoom room) {
    _allRooms.add(room);
    if (room.state == SocketRoomState.wait && !_waitRooms.contains(room))
      _waitRooms.add(room);
    if (room.state == SocketRoomState.ready && !_readyRooms.contains(room))
      _readyRooms.add(room);
    else if (room.state == SocketRoomState.playing &&
        !_playingRooms.contains(room))
      _playingRooms.add(room);
    else if (room.state == SocketRoomState.done && !_doneRooms.contains(room))
      _doneRooms.add(room);
  }

  void removeRoom(SocketRoom room) {
    if (_allRooms.contains(room)) _allRooms.remove(room);
    if (_waitRooms.contains(room)) _waitRooms.remove(room);
    if (_readyRooms.contains(room)) _readyRooms.remove(room);
    if (_playingRooms.contains(room)) _playingRooms.remove(room);
    if (_doneRooms.contains(room)) _doneRooms.remove(room);
  }

  void clientDisconnect(Socket socket) {
    final user = socket.user;
    if (user != null) {
      final room = _getRoomByUserId(user.id);
      if (room != null) room.leave(socket);
    }
  }

  void log() {
    print(
        'Room log: All(${_allRooms.length}) - Wait(${_waitRooms.length}) - Ready(${_readyRooms.length}) - Done(${_doneRooms.length})');
  }

  @override
  void playerFindRoom(Socket socket, dynamic _data) {
    final Map<String, dynamic> data = AppConverter.parseToMap(_data);
    final User user = socket.user;
    final String type = data['type'] as String;
    SocketRoom room = _readyRooms.firstWhere((_room) {
      return _room.languageCode == user.languageCode &&
          _room.countMember < SocketRoom.maxMember;
    }, orElse: () => null);
    room ??= _waitRooms.firstWhere((_room) {
      return _room.languageCode == user.languageCode &&
          _room.countMember < SocketRoom.maxMember;
    },
        orElse: () => SocketRoom(
            state: SocketRoomState.wait,
            type: AppConverter.stringToEnum(type, SocketRoomType.values),
            members: [socket],
            languageCode: user.languageCode));
    room.join(socket);
    addRoom(room);
    log();
  }

  @override
  void playerLeaveRoom(Socket socket, dynamic _data) {
    final Map<String, dynamic> data = AppConverter.parseToMap(_data);
    final user = socket.user;
    final room = _getRoomByUserId(user?.id);
    if (room != null) room.leave(socket);
    log();
  }

  @override
  void playerReady(Socket socket, dynamic _data) {
    final Map<String, dynamic> data = AppConverter.parseToMap(_data);
    final user = socket.user;
    final room = _getRoomByUserId(user.id);
    if (room != null) room.ready(socket);
    log();
  }

  @override
  void playerChat(Socket socket, _data, SocketManagerChatChannel channel) {
    final Map<String, dynamic> data = AppConverter.parseToMap(_data);
    final user = socket.user;
    final room = _getRoomByUserId(user?.id);
    switch (channel) {
      case SocketManagerChatChannel.villager:
        room.sendMessageRoom('[12] ${user.fullName}: ${data['msg']}',
            translation: false);
        break;
      case SocketManagerChatChannel.wolf:
        room.sendMessageWolfChanel('[12] ${user.fullName}: ${data['msg']}',
            translation: false);
        break;
      case SocketManagerChatChannel.die:
        room.sendMessageDieChanel('[12] ${user.fullName}: ${data['msg']}',
            translation: false);
        break;
    }
  }

  @override
  void playerVote(Socket socket, _data, SocketManagerVoteChannel channel) {
    // TODO: implement playerVote
  }
}
