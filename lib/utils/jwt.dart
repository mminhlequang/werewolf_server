import '../werewolf_server.dart';

enum JWTType { success, expired, error }

class JWTResponse {
  final JWTType type;
  final User data;
  const JWTResponse({this.data, this.type});
}

class AppJWT {
  static String _secretKey;
  static int _expiredsInDay;

  static void init({String secretKey, int expiredsInDay}) {
    _secretKey = secretKey;
    _expiredsInDay = expiredsInDay;
  }

  static bool isValid(String accessToken) =>
      verify(accessToken).type == JWTType.success;

  static String generator(Map data) {
    // Create a json web token
    final jwt = JWT({'user': data});

    // Sign it (default with HS256 algorithm)
    return jwt.sign(SecretKey(_secretKey),
        expiresIn: Duration(days: _expiredsInDay));
  }

  static JWTResponse verify(String token) {
    JWTType type;
    User data = User();
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      print('Payload: ${jwt.payload}');
      data.readFromMap(
          jsonDecode(jsonEncode(jwt.payload)) as Map<String, dynamic>);
      type = JWTType.success;
    } on JWTExpiredError {
      type = JWTType.expired;
    } on JWTError catch (ex) {
      type = JWTType.error;
      print(ex.message); // ex: invalid signature
    }
    return JWTResponse(type: type, data: data);
  }
}
