class JsonHelper {
  static int parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.parse(value);
    if (value is double) return value.toInt();
    throw FormatException('Cannot convert $value to int');
  }

  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is String) return double.parse(value);
    if (value is int) return value.toDouble();
    throw FormatException('Cannot convert $value to double');
  }
}
