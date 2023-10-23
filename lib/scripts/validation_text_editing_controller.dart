import 'package:flutter/material.dart';

/// A [TextEditingController] that can be used to validate its text using a [validator].
class ValidationTextEditingController extends TextEditingController {
  final bool Function(String)? validator;

  ValidationTextEditingController({super.text, this.validator});

  bool get valid => validator?.call(text) ?? true;
}
