import 'package:debt/tools.dart';
import 'package:flutter/material.dart';

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final bool autofocus;
  final void Function()? onEditingComplete;

  const DescriptionField({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: null,
        autofocus: autofocus,
        decoration: DebtInputDecoration(context, labelText: 'Description (optional)'),
        onEditingComplete: onEditingComplete,
      );
}
