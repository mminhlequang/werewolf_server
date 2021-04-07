import 'package:socket_io/socket_io.dart';
import 'socket_constant.dart';
import 'socket_controller_interface.dart';
import 'socket_manager.dart';

class SocketController extends SocketControllerInterface {
  Socket _socket;
  SocketManager _manager;

  SocketController(Socket socket) {
    _socket = socket;
    _manager = SocketManager();
    findRoom();
    ready();
    leaveRoom();
  }

  @override
  void findRoom() {
    _socket.on(SocketConstant.onFindRoom, (data) {
      print("Socket listen findRoom: $data - ${_socket.data}");
      _manager.playerFindRoom(_socket, data);
    });
  }

  @override
  void ready() {
    _socket.on(SocketConstant.onReadyPlayer, (data) {
      print("Socket listen ready: $data");
      _manager.playerReady(_socket, data);
    });
  }

  @override
  void leaveRoom() {
    _socket.on(SocketConstant.onLeaveRoom, (data) {
      print("Socket listen leaveRoom: $data");
      _manager.playerLeaveRoom(_socket, data);
    });
  }
}
