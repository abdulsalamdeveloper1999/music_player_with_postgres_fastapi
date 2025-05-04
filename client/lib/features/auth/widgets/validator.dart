String? validateField(String? value, String hinttext) {
  if (value == null || value.isEmpty) {
    return 'This $hinttext cannot be empty';
  }
  return null;
}
