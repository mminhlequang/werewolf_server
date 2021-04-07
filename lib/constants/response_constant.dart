import 'package:werewolf_server/werewolf_server.dart';

import 'constants.dart';

class ResponseConstant {
  static Map<String, dynamic> responseNotFound({String code}) => {
        "success": false,
        "msg": AppMessages.getMessage("request_not_found", code: code),
        "data": null
      };

  static Map<String, dynamic> responseSuccess(dynamic data,
          {String msg = "request_success", String code}) =>
      {
        "success": true,
        "msg": AppMessages.getMessage(msg, code: code),
        "data": jsonDecode(jsonEncode(data))
      };

  static Map<String, dynamic> responseError(
          {String msg = "request_error", bool translate = true, String code}) =>
      {
        "success": false,
        "msg": translate ? AppMessages.getMessage(msg, code: code) : msg,
        "data": null
      };

  static Map<String, dynamic> responseForbidden({String code}) => {
        "success": false,
        "msg": AppMessages.getMessage("request_forbidden", code: code),
        "data": null
      };
}
