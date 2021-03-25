import '../werewolf_server.dart';

enum JWTType { success, expired, error }

class JWTResponse<T> {
  final JWTType type;
  final T data;
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

  static String generator<T>(T data) {
    // Create a json web token
    final jwt = JWT(
      {
        'id': 123,
        'server': {
          'id': '3e4fc296',
          'loc': 'euw-2',
        }
      },
      issuer: 'https://github.com/jonasroussel/jsonwebtoken',
    );

    // Sign it (default with HS256 algorithm)
    return jwt.sign(SecretKey(_secretKey),
        expiresIn: Duration(days: _expiredsInDay));
  }

  static JWTResponse<T> verify<T>(String token) {
    JWTType type;
    T data;
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      print('Payload: ${jwt.payload}');
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
