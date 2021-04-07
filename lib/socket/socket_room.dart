import 'package:socket_io/socket_io.dart';
import 'package:werewolf_server/constants/constants.dart';
import 'package:werewolf_server/entity/entity.dart';
import 'package:werewolf_server/utils/converter.dart';

enum SocketUserState { ready, prepare }

enum SocketRoomType { normal, rank }

enum SocketRoomState { wait, ready, playing, done }

class SocketRoom {
  static const int maxMember = 16;
  static const int minMember = 1;

  SocketRoomType type;
  SocketRoomState state;
  List<Socket> members;
  String languageCode;
  String id;

  SocketRoom(
      {this.members,
      this.type,
      this.languageCode = AppValues.defaultLanguageCode,
      this.state = SocketRoomState.wait,
      String id}) {
    this.id = id ?? DateTime.now().microsecondsSinceEpoch.toString();
  }

  int get countMember => members?.length ?? 0;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": AppConverter.enumToString(type),
      "state": AppConverter.enumToString(state),
      "members": members.map((e) => (e.data['user'] as User).toJson()).toList(),
      "languageCode": languageCode
    };
  }
}
