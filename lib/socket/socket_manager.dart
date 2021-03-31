import 'package:socket_io/socket_io.dart';

import 'socket_room.dart';

class SocketManager {
  final List<SocketRoom> _allRooms = [];
  final List<SocketRoom> _waitRooms = [];
  final List<SocketRoom> _playingRooms = [];
  Server _io;

  SocketManager._();

  static SocketManager _instance;

  factory SocketManager() => _instance ??= SocketManager._();

  void init(Server io) {
    _io = io;
  }

  void _addRoom(SocketRoom room) {
    _allRooms.add(room);
    if (room.type == SocketRoomType.wait) _waitRooms.add(room);
    if (room.type == SocketRoomType.playing) _playingRooms.add(room);
  }

  void _removeRoom(SocketRoom room) {
    if (_allRooms.contains(room)) _allRooms.remove(room);
    if (_waitRooms.contains(room)) _allRooms.remove(room);
    if (_playingRooms.contains(room)) _allRooms.remove(room);
  }

  void findRoom() {}
}
