import 'package:debt/scripts/classes.dart';
import 'package:debt/themes.dart';
import 'package:debt/tools.dart';
import 'package:debt/widgets/debt_edit_dialog.dart';
import 'package:debt/widgets/selection_controller.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ConfirmAction {
  final String name;
  final IconData icon;
  final bool accentColor;
  List<DebtItem> Function(List<DebtItem>, SelectionController<DebtItem>) onConfirm;

  ConfirmAction._(this.name, this.icon, this.accentColor, this.onConfirm);
}

abstract class ConfirmActions {
  static final check = ConfirmAction._(
    'check',
    Symbols.check_circle,
    true,
    (items, selection) => [
      for (final i in items) selection.isSelected(i) ? i.withChecked(true) : i,
    ],
  );

  static final uncheck = ConfirmAction._(
    'uncheck',
    Symbols.unpublished,
    false,
    (items, selection) => [
      for (final i in items) selection.isSelected(i) ? i.withChecked(false) : i,
    ],
  );

  static final delete = ConfirmAction._(
    'delete',
    Symbols.delete,
    true,
    (items, selection) => [
      for (final i in items)
        if (!selection.isSelected(i)) i,
    ],
  );

  static final List<ConfirmAction> values = [check, uncheck, delete];
}

class ConfirmButton extends StatelessWidget {
  final ConfirmAction action;
  final List<DebtItem> items;
  final SelectionController<DebtItem> selection;
  final void Function(List<DebtItem>?) onConfirm;

  const ConfirmButton({
    super.key,
    required this.action,
    required this.onConfirm,
    required this.items,
    required this.selection,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: action.name.toFirstUpperCase(),
        icon: Icon(
          action.icon,
          color: action.accentColor ? DebtColors.of(context).accent : null,
        ),
        onPressed: () => showDialog<List<DebtItem>>(
          context: context,
          builder: (context) => ConfirmDialog(
            action: action,
            items: items,
            selection: selection,
          ),
        ).then(onConfirm),
      );
}

class ConfirmDialog extends StatelessWidget {
  final ConfirmAction action;
  final List<DebtItem> items;
  final SelectionController<DebtItem> selection;

  const ConfirmDialog({
    super.key,
    required this.action,
    required this.items,
    required this.selection,
  });

  @override
  Widget build(BuildContext context) => DebtDialog(
        title: '${action.name.toFirstUpperCase()} confirmation',
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Are you sure you want to ${action.name}'
            ' ${selection.length > 1 ? 'multiple items' : 'this item'}?',
          ),
        ),
        action: action.name.toFirstUpperCase(),
        onAction: () => Navigator.of(context).pop(action.onConfirm(items, selection)),
      );
}
