import '_en.dart';
import '_vi.dart';

class AppMessages {
  static const List<String> languageCodeSupport = ["vi", "en"];
  static const String languageCodeSupportDefault = "vi";

  static final Map<String, Map<String, String>> _messages = {
    "vi": viMessages,
    "en": enMessages
  };

  static String getMessage(String key, {String code, List<String> values}) {
    code ??= languageCodeSupportDefault;
    values ??= [];
    if (key == null || key.isEmpty || !_messages[code].containsKey(key))
      return "Key is null!";
    String msg = _messages[code][key];
    if (!msg.contains('\$')) {
      return msg;
    }
    final List<String> messages = msg.split('\$');
    msg = '';
    messages.forEach((e) => msg +=
        '$e${'${messages.indexOf(e) < values.length ? values[messages.indexOf(e)] : ''}'}');
    return msg;
  }
}
