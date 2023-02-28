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

  static T direct<T>(dynamic input, {T Function()? orElse}) {
    if (input is T) {
      return input;
    } else if (orElse != null) {
      return orElse();
    }
    throw "Unable to map $input to the requested type ${T.runtimeType.toString()}";
  }
}
