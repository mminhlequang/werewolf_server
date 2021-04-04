import '../werewolf_server.dart';

class AppDatabase {
  static Db _db;

  static bool get isConnected => _db?.isConnected;
  static DbCollection get colConfig => _db?.collection("config");
  static DbCollection get colUser => _db?.collection("user");
  static DbCollection get colUserSocial => _db?.collection("user_social");
  static DbCollection get colUserToken => _db?.collection("user_token");
  static DbCollection get colRole => _db?.collection("role");
  static DbCollection get colLanguage => _db?.collection("language");
  static DbCollection get colSectarian => _db?.collection("sectarian");

  static Future init(
      {String username,
      String password,
      String host,
      String databaseName}) async {
    if (_db == null || !_db.isConnected) {
      _db = await Db.create(
          "mongodb+srv://$username:$password@$host/$databaseName?retryWrites=true&w=majority");
      await _db.open();
    }
  }
}
