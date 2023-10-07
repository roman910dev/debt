import 'package:debt/tools.dart';
import 'package:flutter/material.dart';

class DateField extends StatefulWidget {
  final TextEditingController controller;
  const DateField({super.key, required this.controller});

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  Future<void> _onTap() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.utc(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => widget.controller.text = date.toFormattedString());
  }

  void _setInitialDate() {
    if (widget.controller.text.isEmpty) {
      widget.controller.text = DateTime.now().toFormattedString();
    }
  }

  @override
  void initState() {
    super.initState();
    _setInitialDate();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: widget.controller,
        onTap: _onTap,
        readOnly: true,
        mouseCursor: SystemMouseCursors.click,
        decoration: DebtInputDecoration(context, labelText: 'Date'),
      );
}
