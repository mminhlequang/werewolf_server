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
  String languageCode;
  bool isOnline;
  String lastOnline;

  User(
      {this.username,
      this.avatar,
      this.email,
      this.coin = 0,
      this.score = 0,
      this.fullName,
      this.languageCode,
      this.isOnline,
      this.lastOnline,
      String password,
      int id})
      : super(id: id) {
    this.password = convertPassword(password);
  }

  final DbCollection _db = AppDatabase.colUser;

  static String convertPassword(String _pass) {
    if (_pass == null) return "";
    final key = utf8.encode('p@ssw0rd');
    final bytes = utf8.encode(_pass);

    final hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    return hmacSha256.convert(bytes).toString();
  }

  @override
  Future view() async {}

  @override
  Future insert() {
    return _db.insert(toJson());
  }

  @override
  Future update() async {
    final data = await _db.findOne({"id": id});
    toJson().forEach((key, value) {
      if (value != null) {
        data.update(key, (_) => value);
      }
    });
    return _db.update({"id": id}, data);
  }

  @override
  Future delete() {
    return _db.remove(where.eq('id', id));
  }

  static List<User> listFromJson(dynamic json) {
    List<User> data = [];
    if (!(json is List) || json == null) return data;
    json.forEach((e) {
      data.add(User.fromJson(e));
    });
    return data;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      avatar: json['avatar'],
      username: json['username'],
      password: json['password'],
      score: json['score'],
      coin: json['coin'],
      languageCode: json['languageCode'],
      isOnline: json['isOnline'],
      lastOnline: json['lastOnline'],
    );
  }

  @override
  List<Object> get props => [id, email];

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "email": email,
      "avatar": avatar,
      "username": username,
      "password": password,
      "score": score,
      "coin": coin,
      "lastOnline": lastOnline,
      "isOnline": isOnline,
      "languageCode": languageCode
    };
  }
}
