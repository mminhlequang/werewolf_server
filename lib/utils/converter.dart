import 'dart:convert';

class AppConverter {
  AppConverter._();

  static Map<String, dynamic> parseToMap(dynamic data) {
    try {
      if (data is String)
        return jsonDecode(data) as Map<String, dynamic>;
      else
        return jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
    } catch (e) {
      print('Error in parseToMap: $e');
      return {};
    }
  }

  static String enumToString(Object enumEntry) {
    final String description = enumEntry.toString();
    final int indexOfDot = description.indexOf('.');
    assert(
      indexOfDot != -1 && indexOfDot < description.length - 1,
      'The provided object "$enumEntry" is not an enum.',
    );
    return description.substring(indexOfDot + 1);
  }

  static T stringToEnum<T>(String string, List<T> values) {
    return values.firstWhere((e) => enumToString(e) == string,
        orElse: () => null);
  }
}
