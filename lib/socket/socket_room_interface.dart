import 'package:socket_io/socket_io.dart';

abstract class SocketRoomInterface {
  void join(Socket socket);

  void ready(Socket socket);

  void leave(Socket socket);

  void roomPlay();

  void timeControlStart();
}
