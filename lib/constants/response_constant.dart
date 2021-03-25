import 'constans.dart';

class ResponseConstant {
  static Map<String, dynamic> reponseNotFound({String code}) => {
        "success": false,
        "msg": AppMessages.getMessage("request_not_found", code: code),
        "data": null
      };
  static Map<String, dynamic> reponseSuccess(dynamic data,
          {String msg = "request_success", String code}) =>
      {
        "success": true,
        "msg": AppMessages.getMessage(msg, code: code),
        "data": data
      };
  static Map<String, dynamic> reponseError(
          {String msg = "request_error", bool translate = true, String code}) =>
      {
        "success": false,
        "msg": translate ? AppMessages.getMessage(msg, code: code) : msg,
        "data": null
      };
  static Map<String, dynamic> reponseForbidden({String code}) => {
        "success": false,
        "msg": AppMessages.getMessage("request_forbidden", code: code),
        "data": null
      };
}
