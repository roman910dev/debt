import 'package:debt/config.dart';
import 'package:debt/tools.dart';
import 'package:debt/widgets/debt_edit_dialog.dart';
import 'package:flutter/material.dart';

class ThemeDialog extends StatelessWidget {
  const ThemeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeMode option = DebtSettings.theme;
    return DebtDialog(
      title: 'Select Theme',
      content: StatefulBuilder(
        builder: (context, setState) => Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 150),
          child: ListView.builder(
            itemCount: ThemeMode.values.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) => RadioListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              title: Text(ThemeMode.values[i].name.toFirstUpperCase()),
              value: ThemeMode.values[i],
              groupValue: option,
              activeColor: Theme.of(context).colorScheme.secondary,
              onChanged: (val) {
                if (val != null) setState(() => option = val);
              },
            ),
          ),
        ),
      ),
      action: 'Save',
      onAction: () {
        final bool changed = DebtSettings.theme != option;
        if (changed) DebtSettings.theme = option;
        Navigator.of(context).pop(changed);
      },
    );
  }
}