import '../werewolf_server.dart';

class AppDatabase {
  static Db _db;

  static bool get isConnected => _db?.isConnected;
  static DbCollection get colConfig => _db?.collection("col_config");
  static DbCollection get colUser => _db?.collection("col_user");
  static DbCollection get colUserSocial => _db?.collection("col_user_social");
  static DbCollection get colUserToken => _db?.collection("col_user_token");

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
