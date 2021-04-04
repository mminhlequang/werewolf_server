String describeEnum(Object enumEntry) {
  final String description = enumEntry.toString();
  final int indexOfDot = description.indexOf('.');
  assert(
    indexOfDot != -1 && indexOfDot < description.length - 1,
    'The provided object "$enumEntry" is not an enum.',
  );
  return description.substring(indexOfDot + 1);
}

T stringToEnum<T>(String string, List<T> values) {
  return values.firstWhere((e) => describeEnum(e) == string,
      orElse: () => null);
}
