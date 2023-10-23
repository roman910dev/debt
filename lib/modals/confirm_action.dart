import 'package:debt/scripts/classes.dart';
import 'package:debt/tools.dart';
import 'package:debt/modals/debt_dialog.dart';
import 'package:debt/scripts/selection_controller.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// An action on a list of [DebtItem]s and a selection that only requires a confirmation from the user.
///
/// For example, *edit* is not included here because it needs some input from the user,
/// not just a confirmation.
///
/// It is defined by a [name], an [icon], and an action ([onConfirm]).
class ConfirmAction {
  final String name;
  final IconData icon;
  List<DebtItem> Function(List<DebtItem>, SelectionController<DebtItem>)
      onConfirm;

  ConfirmAction._(this.name, this.icon, this.onConfirm);
}

/// Abstract class containing some [ConfirmAction]s.
abstract class ConfirmActions {
  static final check = ConfirmAction._(
    'check',
    Symbols.check_circle,
    (items, selection) => [
      for (final i in items) selection.isSelected(i) ? i.withChecked(true) : i,
    ],
  );

  static final uncheck = ConfirmAction._(
    'uncheck',
    Symbols.unpublished,
    (items, selection) => [
      for (final i in items) selection.isSelected(i) ? i.withChecked(false) : i,
    ],
  );

  static final delete = ConfirmAction._(
    'delete',
    Symbols.delete,
    (items, selection) => [
      for (final i in items)
        if (!selection.isSelected(i)) i,
    ],
  );

  static final List<ConfirmAction> values = [check, uncheck, delete];
}

/// An icon button that opens a [ConfirmDialog] based on [action].
///
/// When the dialog is closed, [onConfirm] is called with the result.
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
        icon: Icon(action.icon),
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

/// A dialog that asks the user to confirm an [action] on some [items] and a [selection].
///
/// Upon confirmation, [action.onConfirm] is called and the result is passed in the [Navigator.pop] call.
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
            ' ${selection.size > 1 ? 'multiple items' : 'this item'}?',
          ),
        ),
        action: action.name.toFirstUpperCase(),
        onAction: () =>
            Navigator.of(context).pop(action.onConfirm(items, selection)),
      );
}
