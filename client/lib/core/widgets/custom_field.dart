import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool readOnly;
  final Function()? onTap;
  const CustomField({
    this.onTap,
    super.key,
    this.readOnly = false,
    required this.hintText,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      readOnly: readOnly,
      validator: validator,
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
    );
  }
}
