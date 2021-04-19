import 'api.dart';
import 'api_interface.dart';

class AppRepository {
  AppRepository._(this._api);

  static AppRepository _instance;

  factory AppRepository({AppApi api}) {
    if (_instance == null)
      _instance = AppRepository._(api ?? AppApiImp());
    else if (api != null) _instance._api = api;
    return _instance;
  }

  AppApiImp _api;

  Future verifyTokenGoogle(String token) async {
    return await _api.verifyTokenGoogle(token, (data) {});
  }

  Future verifyTokenFacebook(String token) async {
    return await _api.verifyTokenFacebook(token, (data) {});
  }
}
