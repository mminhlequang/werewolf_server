class SocketConstant {
  SocketConstant._();

  static const String onFindRoom = 'on_find_room';
  static const String onReadyPlayer = 'on_ready_player';
  static const String onLeaveRoom = 'on_leave_room';

  static const String onVillagerVote = 'on_villager_vote';
  static const String onWolfVote = 'on_wolf_vote';

  static const String onVillagerChat = 'on_villager_chat';
  static const String onWolfChat = 'on_wolf_chat';
  static const String onDieChat = 'on_die_chat';

  static const String emitInfoRoom = 'on_info_room';
  static const String emitJoinRoom = 'on_join_room';
  static const String emitReadyRoom = 'on_ready_room';
  static const String emitRolePlayer = 'on_role_player';
  static const String emitPlayRoom = 'on_play_room';

  static const String emitTimeControl = 'on_time_control';
  static const String emitVillagerVoteStart = 'on_villager_vote_start';
  static const String emitVillagerVote = 'on_villager_vote';
  static const String emitVillagerVoteEnd = 'on_villager_vote_end';
  static const String emitWolfVoteStart = 'on_wolf_vote_start';
  static const String emitWolfVote = 'on_wolf_vote';
  static const String emitWolfVoteEnd = 'on_wolf_vote_end';

  static const String emitMessageSystem = 'on_message_system';
  static const String emitMessageRoom = 'on_message_room';
  static const String emitMessageWolf = 'on_message_wolf';
  static const String emitMessageDie = 'on_message_die';
}
