import '../werewolf_server.dart';

enum JWTType { success, expired, error }

class JWTResponse {
  final JWTType type;
  final User data;

  const JWTResponse({this.data, this.type});

  bool get isSuccess => type == JWTType.success;
}

class AppJWT {
  static String _secretKey;
  static int _expiredsInDay;

  static void init({String secretKey, int expiredInDay}) {
    _secretKey = secretKey;
    _expiredsInDay = expiredInDay;
  }

  static bool isValid(String accessToken) =>
      verify(accessToken).type == JWTType.success;

  static String generator(User user) {
    final jwt = JWT({'user': user?.toJson()});

    // Sign it (default with HS256 algorithm)
    return jwt.sign(SecretKey(_secretKey),
        expiresIn: Duration(days: _expiredsInDay));
  }

  static JWTResponse verify(String token) {
    JWTType type;
    User data = User();
    try {
      final jwt = JWT.verify(token.trim(), SecretKey(_secretKey));
      print('Payload: ${jwt.payload}');
      final Map<String, dynamic> payload =
          jsonDecode(jsonEncode(jwt.payload)) as Map<String, dynamic>;
      if (payload == null || payload['user'] == null)
        throw JWTError('Payload info can\'t by null!');
      data = data.fromJson(payload['user'] as Map<String, dynamic>) as User;
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
