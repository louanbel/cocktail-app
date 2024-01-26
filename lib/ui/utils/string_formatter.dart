class StringFormatter {

  static String format(String? value, int length) {
    if(value == null) return "";

    return value.length > length ? "${value.substring(0, length)}..." : value;
  }
}
