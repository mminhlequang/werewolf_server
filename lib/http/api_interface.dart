abstract class AppApi {
  Future<T> verifyTokenGoogle<T>(String token,converter);

  Future<T> verifyTokenFacebook<T>(String token,converter);

  Future<T> verifyTokenTwitter<T>(String token,converter);
}
