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
    ///Test
    roles = (await AppDatabase.colRole
            .find(where.eq('languageId', 1).eq('sectarians', [2]).limit(1))
            .toList())
        .toRoles;
    return;
    final countVillager = (countMember / 2).floor() + 2;
    final countOther = countMember <= 14 ? 1 : 2;
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

  sendMessageSystem(Socket socket, String msg,
          {List<String> values, bool translation = true}) =>
      socket.emit(SocketConstant.emitMessageSystem, {
        'msg': !translation ? msg : AppMessages.getMessage(msg, values: values)
      });

  sendMessageRoom(String msg, {List<String> values, bool translation = true}) =>
      _manager.io.to(id).emit(SocketConstant.emitMessageRoom, {
        'msg': !translation ? msg : AppMessages.getMessage(msg, values: values)
      });

  sendMessageWolfChanel(String msg,
          {List<String> values, bool translation = true}) =>
      _manager.io.to(wolfChannel).emit(SocketConstant.emitMessageWolf, {
        'msg': !translation ? msg : AppMessages.getMessage(msg, values: values)
      });

  sendMessageDieChanel(String msg,
          {List<String> values, bool translation = true}) =>
      _manager.io.to(dieChannel).emit(SocketConstant.emitMessageDie, {
        'msg': !translation ? msg : AppMessages.getMessage(msg, values: values)
      });

  @override
  void join(Socket socket) {
    if (!members.contains(socket)) members.add(socket);
    socket.join(id);
    socket.emit(SocketConstant.emitInfoRoom, toJson());
    sendMessageRoom('room_welcome', values: [socket.user?.fullName]);
    _manager.io.to(id).emit(SocketConstant.emitJoinRoom, toJson());
  }

  @override
  void leave(Socket socket) {
    if (members.contains(socket)) {
      members.remove(socket);
      if (countMember == 0) _manager.removeRoom(this);
      sendMessageRoom('room_leave', values: [socket.user?.fullName]);
      socket.leave(id, (x) => print('Leave room callback: $x'));
    }
  }

  @override
  void ready(Socket socket) async {
    if (!members.contains(socket)) return;
    sendMessageRoom('room_user_ready', values: [socket.user?.fullName]);
    socket.state = SocketUserState.ready;
    if (countMember >= SocketRoom.minMember &&
        allReady &&
        state == SocketRoomState.wait) {
      _manager.removeRoom(this);
      state = SocketRoomState.ready;
      _manager.addRoom(this);

      //Random role for all player
      await getRoles();

      sendMessageRoom('room_ready', values: ['$beforeStart']);
      _manager.io.to(id).emit(SocketConstant.emitReadyRoom, {
        'before': beforeStart,
        'roles': roles.map((e) => e.toJson()).toList()
      });

      //Send role to player
      Future.delayed(const Duration(seconds: beforeStart), () {
        List<Role> _roles = List.from(roles);
        _roles.shuffle();
        for (int i = 0; i < countMember; i++) {
          members[i].role = _roles[i];
          sendMessageSystem(members[i], 'room_user_role',
              values: [_roles[i].name, _roles[i].description]);
          members[i].emit(SocketConstant.emitRolePlayer, _roles[i].toJson());

          //If player is wolf: Join to wolf channel
          if (_roles[i].sectarians.contains(2)) members[i].join(wolfChannel);
          //Play room
          if (i == countMember - 1) roomPlay();
        }
      });
    }

    ///Test
    _manager.removeRoom(this);
    state = SocketRoomState.ready;
    _manager.addRoom(this);

    //Random role for all player
    await getRoles();

    sendMessageRoom('room_ready', values: ['$beforeStart']);
    _manager.io.to(id).emit(SocketConstant.emitReadyRoom, {
      'before': beforeStart,
      'roles': roles.map((e) => e.toJson()).toList()
    });

    //Send role to player
    Future.delayed(const Duration(seconds: beforeStart), () {
      for (int i = 0; i < countMember; i++) {
        members[i].role = roles[i];
        sendMessageSystem(members[i], 'room_user_role',
            values: [roles[i].name, roles[i].description]);
        members[i].emit(SocketConstant.emitRolePlayer, roles[i].toJson());

        //If player is wolf: Join to wolf channel
        if (roles[i].sectarians.contains(2)) members[i].join(wolfChannel);
        //Play room
        if (i == countMember - 1) roomPlay();
      }
    });
  }

  @override
  void roomPlay() async {
    if (state == SocketRoomState.playing) return;
    state = SocketRoomState.playing;
    await Future.delayed(Duration(seconds: 5));
    sendMessageRoom('room_start_play');
    _manager.io.to(id).emit(SocketConstant.emitPlayRoom);
    timeControlStart();
  }

  @override
  void timeControlStart() async {
    day = 1;
    timeState = SocketRoomTimeState.morning;
    while (state != SocketRoomState.done) {
      //Morning
      sendMessageRoom('start_morning', values: ['$day']);
      _manager.io.to(id).emit(SocketConstant.emitTimeControl,
          SocketEmitFormat.success(msg: 'start_morning', values: ['$day']));
      await Future.delayed(Duration(seconds: timeDiscuss));
      sendMessageRoom('villager_vote', values: ['$day']);
      _manager.io.to(id).emit(
          SocketConstant.emitVillagerVoteStart,
          SocketEmitFormat.success(
              msg: 'villager_vote', values: ['$day'], data: timeVillagerVote));
      await Future.delayed(Duration(seconds: timeVillagerVote));

      //Vote success?
      if (false) {
        var someone;
        sendMessageRoom('villager_vote_someone', values: ['$day', 'someone']);
        _manager.io.to(id).emit(
            SocketConstant.emitVillagerVoteEnd,
            SocketEmitFormat.success(
                msg: 'villager_vote_someone', values: ['$day', '$someone']));
      } else {
        sendMessageRoom('villager_vote_not_someone', values: ['$day']);
        _manager.io.to(id).emit(
            SocketConstant.emitVillagerVoteEnd,
            SocketEmitFormat.success(
                msg: 'villager_vote_not_someone', values: ['$day']));
      }

      //Evening
      timeState = SocketRoomTimeState.evening;
      sendMessageRoom('start_evening', values: ['$day']);
      _manager.io.to(id).emit(SocketConstant.emitTimeControl,
          SocketEmitFormat.success(msg: 'start_evening', values: ['$day']));
      _manager.io.to(wolfChannel).emit(
          SocketConstant.emitWolfVoteStart,
          SocketEmitFormat.success(
              msg: 'wolf_vote', values: ['$day'], data: timeVillagerVote));
      await Future.delayed(Duration(seconds: timeWolfVote));
      //Vote success?
      if (false) {
        var someone;
        sendMessageRoom('wolf_vote_someone', values: ['$day', 'someone']);
        _manager.io.to(wolfChannel).emit(
            SocketConstant.emitWolfVoteEnd,
            SocketEmitFormat.success(
                msg: 'wolf_vote_someone', values: ['$day', '$someone']));
      } else {
        sendMessageRoom('wolf_vote_not_someone', values: ['$day']);
        _manager.io.to(wolfChannel).emit(
            SocketConstant.emitWolfVoteEnd,
            SocketEmitFormat.success(
                msg: 'wolf_vote_not_someone', values: ['$day']));
      }

      //New day
      day++;
      timeState = SocketRoomTimeState.morning;
    }
  }
}
