extension StringExtensions on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isValidEmail {
    final regex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");
    return regex.hasMatch(this);
  }

  bool get isValidPhone {
    // Basic validation for UAE phone numbers (+971 or 05...)
    final regex = RegExp(r'^(\+971|0)?5[0-9]{8}$');
    return regex.hasMatch(this);
  }
}
