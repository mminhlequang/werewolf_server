import '_en.dart';
import '_vi.dart';

class AppMessages {
  static const List<String> languageCodeSupport = ["vi", "en"];
  static const String languageCodeSupportDefault = "vi";

  static final Map<String, Map<String, String>> _messages = {
    "vi": viMessages,
    "en": enMessages
  };

  static String getMessage(String key, {String code}) {
    code ??= languageCodeSupportDefault;
    if (key == null || key.isEmpty || !_messages[code].containsKey(key))
      return "Key is null!";
    return _messages[code][key];
  }
}
