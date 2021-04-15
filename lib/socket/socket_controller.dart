import 'package:socket_io/socket_io.dart';
import 'package:werewolf_server/socket/socket_manager_interface.dart';
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
    villagerChat();
    villagerVote();
    wolfVote();
    wolfChat();
    dieChat();
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

  @override
  void dieChat() {
    _socket.on(SocketConstant.onDieChat, (data) {
      print("Socket listen dieChat: $data");
      _manager.playerChat(_socket, data, SocketManagerChatChannel.die);
    });
  }

  @override
  void villagerChat() {
    _socket.on(SocketConstant.onReadyPlayer, (data) {
      print("Socket listen villagerChat: $data");
      _manager.playerChat(_socket, data, SocketManagerChatChannel.villager);
    });
  }

  @override
  void wolfChat() {
    _socket.on(SocketConstant.onReadyPlayer, (data) {
      print("Socket listen wolfChat: $data");
      _manager.playerChat(_socket, data, SocketManagerChatChannel.wolf);
    });
  }

  @override
  void villagerVote() {
    _socket.on(SocketConstant.onReadyPlayer, (data) {
      print("Socket listen villagerVote: $data");
      _manager.playerVote(_socket, data, SocketManagerVoteChannel.villager);
    });
  }

  @override
  void wolfVote() {
    _socket.on(SocketConstant.onReadyPlayer, (data) {
      print("Socket listen wolfVote: $data");
      _manager.playerVote(_socket, data, SocketManagerVoteChannel.wolf);
    });
  }
}
