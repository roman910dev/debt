import 'package:debt/config.dart';
import 'package:debt/scripts/classes.dart';
import 'package:debt/tools.dart';
import 'package:debt/widgets/date_field.dart';
import 'package:debt/widgets/debt_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditDialog extends StatelessWidget {
  final DebtItem item;
  final String? Function(DebtItem)? validator;

  EditDialog({
    super.key,
    required this.item,
    required this.validator,
  });

  late final TextEditingController _textController = TextEditingController(text: item.text);
  late final TextEditingController _dateController =
      TextEditingController(text: item.date.toFormattedString());

  Widget _buildText(BuildContext context) => TextField(
        controller: _textController,
        autofocus: !DebtData.iOSWeb,
        inputFormatters: [if (item is Person) LengthLimitingTextInputFormatter(25)],
        minLines: 1,
        maxLines: item is Entry ? 5 : 1,
        decoration: DebtInputDecoration(context),
      );

  Widget _buildDate() => DateField(controller: _dateController);

  @override
  Widget build(BuildContext context) => DebtDialog(
      title: 'Edit ${item is Person ? 'name' : 'entry'}',
      content: Column(
        children: [
          _buildText(context),
          if (item is Entry) ...[
            const SizedBox(height: 8),
            _buildDate(),
          ],
        ],
      ),
      action: 'Edit',
      onAction: () {
        DebtItem newItem = item.withText(_textController.text);
        String? error = validator?.call(newItem);
        if (newItem is Entry) {
          final DateTime? date = DebtDateTime.tryParse(_dateController.text);
          if (date == null) {
            error = 'Date is invalid!';
          } else {
            newItem = newItem.withDate(date);
          }
        }
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        } else {
          Navigator.of(context).pop(newItem);
        }
      },
    );
}
