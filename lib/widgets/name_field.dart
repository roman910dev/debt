import 'package:debt/scripts/validation_text_editing_controller.dart';
import 'package:debt/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A text field that allows to input a name for debt items.
/// 
/// If [personName] is not `null`, the field will be disabled and will display [personName].
class NameField extends StatefulWidget {
  /// The name of the person whose name is being edited.
  /// 
  /// If `null`, the field will be enabled.
  final String? personName;

  final ValidationTextEditingController controller;
  
  final bool autofocus;

  final void Function()? onEditingComplete;

  const NameField({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.personName,
    this.onEditingComplete,
  });

  @override
  State<NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<NameField> {
  bool _valid = true;

  void listener() {
    if (widget.controller.valid != _valid) {
      setState(() => _valid = widget.controller.valid);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listener);
    delay(0).then((_) {
      _valid = true;
      if (widget.personName != null) {
        widget.controller.text = widget.personName!;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        enabled: widget.personName == null,
        controller: widget.controller,
        autofocus: widget.autofocus,
        cursorColor: _valid
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.error,
        decoration: DebtInputDecoration(
          context,
          labelText: 'Name',
          valid: _valid,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.singleLineFormatter,
          LengthLimitingTextInputFormatter(25),
        ],
        onEditingComplete: widget.onEditingComplete,
      );
}
