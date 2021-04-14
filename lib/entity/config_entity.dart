import 'dart:async';

import 'package:werewolf_server/utils/utils.dart';
import 'package:werewolf_server/werewolf_server.dart';

import 'entity.dart';

class Config extends EntityBase {
  String versionAndroid;
  int versionNumberAndroid;
  String versionIos;
  int versionNumberIos;
  int requiredVersionAndroid;
  int requiredVersionIos;
  String storeAndroid;
  String storeIos;
  int enableAds;

  Config(
      {this.versionAndroid = "1",
      this.versionNumberAndroid = 1,
      this.versionIos = "1",
      this.versionNumberIos = 1,
      this.requiredVersionAndroid = 1,
      this.requiredVersionIos = 1,
      this.storeAndroid = "",
      this.storeIos = "",
      this.enableAds = 0,
      int id})
      : super(id: id);

  final DbCollection _db = AppDatabase.colConfig;

  @override
  Future view() async {
    final data = await _db.findOne({"id": id});
    print(data);
    return data;
  }

  @override
  Future insert() {
    return _db.insert(toJson());
  }

  @override
  Future update() async {}

  @override
  Future delete() async {}

  static List<Config> listFromJson(dynamic json) {
    List<Config> data = [];
    if (!(json is List) || json == null) return data;
    json.forEach((e) {
      data.add(Config.fromJson(e));
    });
    return data;
  }

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
        id: json["id"] as int,
        versionAndroid: json["version_android"] as String,
        versionNumberAndroid: json["version_number_android"] as int,
        versionIos: json["version_ios"] as String,
        versionNumberIos: json["version_number_ios"] as int,
        requiredVersionAndroid: json["required_version_android"] as int,
        requiredVersionIos: json["required_version_ios"] as int,
        storeAndroid: json["store_android"] as String,
        storeIos: json["store_ios"] as String,
        enableAds: json['enable_ads'] as int);
  }

  @override
  List<Object> get props => throw UnimplementedError();

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["version_android"] = versionAndroid;
    map["version_number_android"] = versionNumberAndroid;
    map["version_ios"] = versionIos;
    map["version_number_ios"] = versionNumberIos;
    map["required_version_android"] = requiredVersionAndroid;
    map["required_version_ios"] = requiredVersionIos;
    map["store_android"] = storeAndroid;
    map["store_ios"] = storeIos;
    map['enable_ads'] = enableAds;
    return map;
  }
}
