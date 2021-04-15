import 'package:socket_io/socket_io.dart';
import 'package:werewolf_server/constants/constants.dart';
import 'package:werewolf_server/entity/entity.dart';
import 'package:werewolf_server/socket/socket_emit_format.dart';
import 'package:werewolf_server/socket/socket_manager.dart';
import 'package:werewolf_server/socket/socket_room_interface.dart';
import 'package:werewolf_server/utils/converter.dart';
import 'package:werewolf_server/werewolf_server.dart';
import '../extensions/extensions.dart';

import 'socket_constant.dart';

enum SocketUserState { ready, prepare, life, die }

enum SocketRoomType { normal, rank }

enum SocketRoomState { wait, ready, playing, done }

enum SocketRoomTimeState { morning, evening }

class SocketRoom extends SocketRoomInterface {
  static const int maxMember = 16;
  static const int minMember = 12;
  static const int beforeStart = 10;
  static const int timeMorning = 60;
  static const int timeDiscuss = 30;
  static const int timeVillagerVote = 30;
  static const int timeEvening = 30;
  static const int timeWolfVote = 30;

  final SocketManager _manager = SocketManager();

  SocketRoomType type;
  SocketRoomState state;
  List<Socket> members;
  String languageCode;
  String id;
  List<Role> roles;

  //Control time
  int day;
  SocketRoomTimeState timeState;

  SocketRoom(
      {this.members,
      this.type,
      this.languageCode = AppValues.defaultLanguageCode,
      this.state = SocketRoomState.wait,
      String id}) {
    this.id = id ?? DateTime.now().microsecondsSinceEpoch.toString();
  }

  int get countMember => members?.length ?? 0;

  String get wolfChannel => '$id-wolf';

  String get dieChannel => '$id-wolf';

  bool get allReady {
    bool status = true;
    for (Socket socket in members) {
      if (socket.state != SocketUserState.ready) status = false;
      break;
    }
    return status;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": AppConverter.enumToString(type),
      "state": AppConverter.enumToString(state),
      "members": members.map((e) => (e.data['user'] as User).toJson()).toList(),
      "languageCode": languageCode
    };
  }

  void getRoles() async {
    if (countMember < minMember) return;
    final countVillager = (countMember / 2).floor();
    final countOther = countMember <= 14 ? 2 : 3;
    final countWolf = countMember - countVillager - countOther;
    final villagers = (await AppDatabase.colRole
            .find(where
                .eq('languageId', 1)
                .eq('sectarians', [1]).limit(countVillager))
            .toList())
        .toRoles;

    final wolfs = (await AppDatabase.colRole
            .find(where
                .eq('languageId', 1)
                .eq('sectarians', [2]).limit(countWolf))
            .toList())
        .toRoles;

    final others = (await AppDatabase.colRole
            .find(where
                .eq('languageId', 1)
                .eq('sectarians', [3]).limit(countOther))
            .toList())
        .toRoles;

    roles = villagers + wolfs + others;
  }

  sendMessage(String msg, {List<String> values}) => _manager.io.to(id).emit(
      SocketConstant.emitMessageRoom,
      SocketEmitFormat.success(msg, values: values));

  sendMessageWolfChanel(String msg, {List<String> values}) =>
      _manager.io.to(wolfChannel).emit(SocketConstant.emitMessageWolf,
          SocketEmitFormat.success(msg, values: values));

  sendMessageDieChanel(String msg, {List<String> values}) =>
      _manager.io.to(dieChannel).emit(SocketConstant.emitMessageDie,
          SocketEmitFormat.success(msg, values: values));

  @override
  void join(Socket socket) {
    if (!members.contains(socket)) members.add(socket);

    ////Test
    for (int i = 0; i < SocketRoom.minMember; i++) {
      socket.state = SocketUserState.ready;
      members.add(socket);
    }
    print('countMember: $countMember - allReady: $allReady');
    /////
    socket.join(id);
    socket.emit(SocketConstant.emitInfoRoom, toJson());
    sendMessage('room_welcome', values: [socket.user?.fullName]);
  }

  @override
  void leave(Socket socket) {
    if (members.contains(socket)) {
      members.remove(socket);
      if (countMember == 0) _manager.removeRoom(this);
      sendMessage('room_leave', values: [socket.user?.fullName]);
      socket.leave(id, (x) => print('Leave room callback: $x'));
    }
  }

  @override
  void ready(Socket socket) async {
    if (!members.contains(socket)) return;
    sendMessage('room_user_ready', values: [socket.user?.fullName]);
    socket.state = SocketUserState.ready;
    if (countMember >= SocketRoom.minMember && allReady) {
      _manager.removeRoom(this);
      state = SocketRoomState.ready;
      _manager.addRoom(this);

      //Random role for all player
      await getRoles();

      _manager.io.to(id).emit(SocketConstant.emitReadyRoom, {
        'msg': AppMessages.getMessage('room_ready', values: ['$beforeStart'])
      });

      //Send role to player
      Future.delayed(const Duration(seconds: beforeStart), () {
        List<Role> _roles = List.from(roles);
        _roles.shuffle();
        for (int i = 0; i < countMember; i++) {
          members[i].role = _roles[i];
          members[i].emit(
              SocketConstant.emitRolePlayer,
              SocketEmitFormat.success('room_user_role',
                  values: [_roles[i].name, _roles[i].description],
                  data: _roles[i].toJson()));

          //If player is wolf: Join to wolf channel
          if(_roles[i].sectarians.contains(3))
            members[i].join(wolfChannel);

          if (i == countMember - 1) {
            roomPlay();
          }
        }
      });
    }
  }

  @override
  void roomPlay() async {
    state = SocketRoomState.playing;
    await Future.delayed(Duration(seconds: 5));
    sendMessage('room_start_play');
    _manager.io.to(id).emit(SocketConstant.emitPlayRoom);
    timeControlStart();
  }

  @override
  void timeControlStart() async {
    day = 1;
    timeState = SocketRoomTimeState.morning;
    while (state != SocketRoomState.done) {
      //Morning
      sendMessage('start_morning', values: ['$day']);
      _manager.io.to(id).emit(SocketConstant.emitTimeControl,
          SocketEmitFormat.success('start_morning', values: ['$day']));
      await Future.delayed(Duration(seconds: timeDiscuss));
      sendMessage('villager_vote', values: ['$day']);
      _manager.io.to(id).emit(
          SocketConstant.emitVillagerVoteStart,
          SocketEmitFormat.success('villager_vote',
              values: ['$day'], data: timeVillagerVote));
      await Future.delayed(Duration(seconds: timeVillagerVote));

      //Vote success?
      if (false) {
        var someone;
        sendMessage('villager_vote_someone', values: ['$day', 'someone']);
        _manager.io.to(id).emit(
            SocketConstant.emitVillagerVoteEnd,
            SocketEmitFormat.success('villager_vote_someone',
                values: ['$day', '$someone']));
      } else {
        sendMessage('villager_vote_not_someone', values: ['$day']);
        _manager.io.to(id).emit(
            SocketConstant.emitVillagerVoteEnd,
            SocketEmitFormat.success('villager_vote_not_someone',
                values: ['$day']));
      }

      //Evening
      timeState = SocketRoomTimeState.evening;
      sendMessage('start_evening', values: ['$day']);
      sendMessageWolfChanel('start_evening', values: ['$day']);
      _manager.io.to(id).emit(SocketConstant.emitTimeControl,
          SocketEmitFormat.success('start_evening', values: ['$day']));
      _manager.io.to(id).emit(
          SocketConstant.emitWolfVoteStart,
          SocketEmitFormat.success('wolf_vote',
              values: ['$day'], data: timeVillagerVote));
      await Future.delayed(Duration(seconds: timeWolfVote));
      //Vote success?
      if (false) {
        var someone;
        sendMessage('wolf_vote_someone', values: ['$day', 'someone']);
        _manager.io.to(id).emit(
            SocketConstant.emitWolfVoteEnd,
            SocketEmitFormat.success('wolf_vote_someone',
                values: ['$day', '$someone']));
      } else {
        sendMessage('wolf_vote_not_someone', values: ['$day']);
        _manager.io.to(id).emit(
            SocketConstant.emitWolfVoteEnd,
            SocketEmitFormat.success('wolf_vote_not_someone',
                values: ['$day']));
      }

      //New day
      day++;
      timeState = SocketRoomTimeState.morning;
    }
  }
}
