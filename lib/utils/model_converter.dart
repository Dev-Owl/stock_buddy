class ModelConverter {
  static List<T> modelList<T>(
    dynamic input,
    T Function(dynamic singleElement) converter,
  ) {
    if (input == null) {
      return [];
    }

    return (input as List<dynamic>).map((e) => converter(e)).toList();
  }

  static T first<T>(
    dynamic input,
    T Function(Map<String, dynamic> singleElement) converter,
  ) {
    if (input is List) {
      return converter((input).first);
    } else {
      return converter(input);
    }
  }
}
