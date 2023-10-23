import 'package:debt/config.dart';
import 'package:debt/scripts/classes.dart';
import 'package:debt/scripts/validation_text_editing_controller.dart';
import 'package:debt/tools.dart';
import 'package:debt/widgets/amount_field.dart';
import 'package:debt/widgets/date_field.dart';
import 'package:debt/modals/debt_dialog.dart';
import 'package:debt/widgets/description_field.dart';
import 'package:debt/widgets/name_field.dart';
import 'package:flutter/material.dart';

/// A dialog that allows the user to add a new entry.
///
/// If [personName] is not `null`, the dialog will be pre-filled with the person's name,
/// which the user will not be able to change.
///
/// Otherwise, the user will be able to set the person.
/// If the user sets a person that does not exist, a new person will be created.
class AddEntryDialog extends StatefulWidget {
  /// The name of the person whom the entry will be added to.
  /// If `null`, the user will be able to set the person.
  final String? personName;

  const AddEntryDialog({super.key, this.personName});

  @override
  createState() => AddEntryDialogState();
}

class AddEntryDialogState extends State<AddEntryDialog> {
  String? _error;

  final _nameController = ValidationTextEditingController(
    validator: (data) => data.isNotEmpty,
  );
  final _descriptionController = TextEditingController();
  final _amountController = AmountFieldController();
  final _dateController = TextEditingController();

  void _onSave() {
    if (!_nameController.valid) {
      _error = 'Name cannot be empty!';
    } else if (_amountController.amount == null) {
      _error = '${DebtSettings.currency.symbol} is invalid!';
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
    setState(() {});
  }

  Widget _buildName() => NameField(
        personName: widget.personName,
        controller: _nameController,
        autofocus: !DebtEnv.iOSWeb && widget.personName == null,
        onEditingComplete: _onSave,
      );

  Widget _buildDescription() => DescriptionField(
        controller: _descriptionController,
        onEditingComplete: _onSave,
      );

  Widget _buildAmount() => AmountField(
        controller: _amountController,
        autofocus: !DebtEnv.iOSWeb && widget.personName != null,
        onEditingComplete: _onSave,
      );

  Widget _buildDate() => DateField(controller: _dateController);

  @override
  Widget build(BuildContext context) => DebtDialog(
        title: 'Add entry',
        action: 'Save',
        onAction: _onSave,
        error: _error,
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
