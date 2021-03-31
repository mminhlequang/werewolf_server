import 'package:socket_io/socket_io.dart';

enum SocketRoomType { wait, playing }

class SocketRoom {
  SocketRoomType type;
  List<Socket> members = [];

  SocketRoom({this.members, this.type});

  int get countMember => members.length;
}
