import 'package:debt/config.dart';
import 'package:debt/scripts/classes.dart';
import 'package:debt/scripts/validation_text_editing_controller.dart';
import 'package:debt/tools.dart';
import 'package:debt/widgets/amount_field.dart';
import 'package:debt/widgets/date_field.dart';
import 'package:debt/widgets/debt_edit_dialog.dart';
import 'package:debt/widgets/description_field.dart';
import 'package:debt/widgets/name_field.dart';
import 'package:flutter/material.dart';

class AddDialog extends StatefulWidget {
  final String? personName;
  const AddDialog({super.key, this.personName});

  @override
  createState() => AddDialogState();
}

class AddDialogState extends State<AddDialog> {
  final _nameController = ValidationTextEditingController(validator: (data) => data.isNotEmpty);
  final _descriptionController = TextEditingController();
  final _amountController = AmountFieldController();
  final _dateController = TextEditingController();

  void _onSave() {
    String? error;
    if (!_nameController.valid) {
      error = 'Name cannot be empty!';
    } else if (_amountController.amount == null) {
      error = '${DebtSettings.currency.symbol} is invalid!';
    } else {
      people.addEntry(
        Entry(
          person: _nameController.text,
          description: _descriptionController.text,
          money: _amountController.amount!,
          date: DebtDateTime.parse(_dateController.text),
        ),
      );
      return Navigator.of(context).pop();
    }
    // FIXME: snackbar over dialog
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  Widget _buildName() => NameField(
        personName: widget.personName,
        controller: _nameController,
        autofocus: !DebtData.iOSWeb && widget.personName == null,
        onEditingComplete: _onSave,
      );

  Widget _buildDescription() => DescriptionField(
        controller: _descriptionController,
        onEditingComplete: _onSave,
      );

  Widget _buildAmount() => AmountField(
        controller: _amountController,
        autofocus: !DebtData.iOSWeb && widget.personName != null,
        onEditingComplete: _onSave,
      );

  Widget _buildDate() => DateField(controller: _dateController);

  @override
  Widget build(BuildContext context) => DebtDialog(
        title: 'Add entry',
        action: 'Save',
        onAction: _onSave,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(flex: 3, child: _buildName()),
                const SizedBox(width: 8),
                Flexible(flex: 2, child: _buildAmount()),
              ],
            ),
            const SizedBox(height: 8),
            _buildDescription(),
            const SizedBox(height: 8),
            _buildDate(),
          ],
        ),
      );
}
