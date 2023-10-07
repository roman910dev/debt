import 'package:flutter/material.dart';

class ValidationTextEditingController extends TextEditingController {
  final bool Function(String)? validator;

  ValidationTextEditingController({super.text, this.validator});

  bool get valid => validator?.call(text) ?? true;
}
