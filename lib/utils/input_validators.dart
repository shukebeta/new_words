class InputValidators {
  static String? Function(String?) required(String errorMessage) {
    return (value) {
      if (value == null || value.isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }

  static String? Function(String?) maxLength(int maxLength, String errorMessage) {
    return (value) {
      if (value != null && value.length > maxLength) {
        return errorMessage;
      }
      return null;
    };
  }

  static String? Function(String?) containsLetter(String errorMessage) {
    return (value) {
      if (value != null && !RegExp(r'[a-zA-Z]').hasMatch(value)) {
        return errorMessage;
      }
      return null;
    };
  }
}