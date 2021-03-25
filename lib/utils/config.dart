import '../werewolf_server.dart';

class WereWolfConfiguration extends Configuration {
  WereWolfConfiguration(String fileName) : super.fromFile(File(fileName));

  String username;
  String password;
  String secretKey;
  String host;
  String databaseName;

  @optionalConfiguration
  String apiBaseURL;

  @optionalConfiguration
  int port;

  @optionalConfiguration
  int identifier;
}
