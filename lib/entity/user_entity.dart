import 'dart:async';

import 'package:werewolf_server/utils/utils.dart';
import 'package:werewolf_server/werewolf_server.dart';

import 'entity.dart';

class User extends EntityBase {
  String username;
  String password;
  String fullName;
  String email;
  String avatar;
  int score;
  int coin;

  User(
      {this.username,
      this.avatar,
      this.email,
      this.coin = 0,
      this.score = 0,
      this.fullName,
      String password,
      int id})
      : super(id: id) {
    this.password = convertPassword(password);
  }

  static String convertPassword(String _pass) {
    final key = utf8.encode('p@ssw0rd');
    final bytes = utf8.encode(_pass);

    final hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    return hmacSha256.convert(bytes).toString();
  }

  @override
  Future view() async {}

  @override
  Future insert() {
    return AppDatabase.colUser.insert(asMap());
  }

  @override
  Future update() async {
    final data = await AppDatabase.colUser.findOne({"id": id});
    asMap().forEach((key, value) {
      if (value != null) {
        data.update(key, (_) => value);
      }
    });
    return AppDatabase.colUser.update({"id": id}, data);
  }

  @override
  Future detete() {
    return AppDatabase.colUser.remove(where.eq('id', id));
  }

  @override
  Map<String, dynamic> asMap() {
    return {
      "id": id,
      "fullName": fullName,
      "email": email,
      "avatar": avatar,
      "username": username,
      "password": password,
      "score": score,
      "coin": coin
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    id = object['id'] as int;
    fullName = object['fullName'] as String;
    email = object['email'] as String;
    avatar = object['avatar'] as String;
    username = object['username'] as String;
    password = object['password'] as String;
    score = object['score'] as int;
    coin = object['coin'] as int;
  }
}
