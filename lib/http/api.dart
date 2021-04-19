import 'package:dio/dio.dart';
import 'package:werewolf_server/http/client.dart';

import 'api_interface.dart';

class AppApiImp extends AppApi {
  @override
  Future<T> verifyTokenFacebook<T>(String token, converter) async {
    Response response = await AppClients(baseUrl: 'https://graph.facebook.com')
        .get('/me', queryParameters: {'access_token': token});
  }

  @override
  Future<T> verifyTokenGoogle<T>(String token, converter) async {
    Response response = await AppClients(baseUrl: 'https://www.googleapis.com')
        .get('/oauth2/v3/tokeninfo', queryParameters: {'id_token': token});
  }

  @override
  Future<T> verifyTokenTwitter<T>(String token, converter) {
    // TODO: implement verifyTokenTwitter
    throw UnimplementedError();
  }
}
