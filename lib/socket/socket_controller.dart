import 'package:socket_io/socket_io.dart';
import 'socket_controller_interface.dart';

class SocketController extends SocketControllerInterface {
  Socket _socket;

  SocketController(Socket socket) {
    _socket = socket;
    findRoom();
    ready();
    leaveRoom();
  }

  @override
  void findRoom() {
    _socket.on("findRoom", (data) {
      print("Socket listen findRoom: $data");
    });
  }

  @override
  void leaveRoom() {
    _socket.on("leaveRoom", (data) {
      print("Socket listen leaveRoom: $data");
      });
  }

  @override
  void ready() {
    _socket.on("ready", (data) {
      print("Socket listen ready: $data");});
  }
}
