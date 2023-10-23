import 'package:debt/config.dart';
import 'package:debt/scripts/classes.dart';
import 'package:debt/tools.dart';
import 'package:debt/widgets/date_field.dart';
import 'package:debt/modals/debt_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A dialog that allows to edit a [DebtItem].
///
/// For [Person]s, it allows to edit the name.
///
/// For [Entry]s, it allows to edit the description and the date.
class EditDialog extends StatefulWidget {
  final DebtItem item;
  final String? Function(DebtItem)? validator;

  const EditDialog({
    super.key,
    required this.item,
    required this.validator,
  });

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  String? _error;

  late final TextEditingController _textController =
      TextEditingController(text: widget.item.text);

  late final TextEditingController _dateController =
      TextEditingController(text: widget.item.date.toFormattedString());

  void _onEdit(BuildContext context) {
    DebtItem newItem = widget.item.withText(_textController.text);
    _error = widget.validator?.call(newItem);
    if (newItem is Entry) {
      final DateTime? date = DebtDateTime.tryParse(_dateController.text);
      if (date == null) {
        _error = 'Date is invalid!';
      } else {
        newItem = newItem.withDate(date);
      }
    }
    if (_error == null) return Navigator.of(context).pop(newItem);
    setState(() {});
  }

  Widget _buildText(BuildContext context) => TextField(
        controller: _textController,
        autofocus: !DebtEnv.iOSWeb,
        inputFormatters: [
          if (widget.item is Person) LengthLimitingTextInputFormatter(25),
        ],
        minLines: 1,
        maxLines: widget.item is Entry ? 5 : 1,
        decoration: DebtInputDecoration(context),
      );

  Widget _buildDate() => DateField(controller: _dateController);

  @override
  Widget build(BuildContext context) => DebtDialog(
        title: 'Edit ${widget.item is Person ? 'name' : 'entry'}',
        content: Column(
          children: [
            _buildText(context),
            if (widget.item is Entry) ...[
              const SizedBox(height: 8),
              _buildDate(),
            ],
          ],
        ),
        error: _error,
        action: 'Edit',
        onAction: () => _onEdit(context),
      );
}
