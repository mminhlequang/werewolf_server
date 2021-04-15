import 'package:socket_io/socket_io.dart';

enum SocketManagerChatChannel{
  die, villager, wolf
}

enum SocketManagerVoteChannel{
  villager, wolf
}

abstract class SocketManagerInterface {
  void playerFindRoom(Socket socket, dynamic _data);

  void playerReady(Socket socket, dynamic _data);

  void playerLeaveRoom(Socket socket, dynamic _data);

  void playerVote(Socket socket, dynamic _data, SocketManagerVoteChannel channel);

  void playerChat(Socket socket, dynamic _data, SocketManagerChatChannel channel);
}
