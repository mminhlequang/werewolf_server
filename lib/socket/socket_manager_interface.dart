import 'package:socket_io/socket_io.dart';

abstract class SocketManagerInterface {
  void playerFindRoom(Socket socket, dynamic _data);

  void playerReady(Socket socket, dynamic _data);

  void playerLeaveRoom(Socket socket, dynamic _data);
}
