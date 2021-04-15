import 'package:werewolf_server/constants/constants.dart';

class SocketEmitFormat {
  SocketEmitFormat._();

  static Map<String, dynamic> success(String msg,
      {String code, List<String> values, dynamic data}) {
    return {
      'success': true,
      'msg': AppMessages.getMessage(msg, values: values),
      'data': data
    };
  }

  static Map<String, dynamic> failure(String msg,
      {String code, List<String> values}) {
    return {
      'success': false,
      'msg': AppMessages.getMessage(msg, values: values)
    };
  }
}
