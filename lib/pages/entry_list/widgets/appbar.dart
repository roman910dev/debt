import 'package:debt/config.dart';
import 'package:debt/modals/add_entry.dart';
import 'package:debt/scripts/classes.dart';
import 'package:debt/modals/confirm_action.dart';
import 'package:debt/modals/edit_entry.dart';
import 'package:debt/pages/entry_list/widgets/menu_button.dart';
import 'package:debt/scripts/selection_controller.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// The app bar for the [MoneyList] page.
///
/// If [personName] is null, the widget will assume that the page is the main one.
/// Otherwise, it will assume that the page is a person's page
/// and will display the person's name in its title.
///
/// [items] and [selection] are required to react to selection changes and
/// to perform actions on the selected items (adding, editing, deleting, etc.).
///
/// [onSettingsChanged] is used as a callback when some of the app's settings are changed.
/// Therefore, this property is only used when [personName] is null (main page).
class EntryListAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// The name of the person whose page is being displayed. Use `null` for the main page.
  final String? personName;

  /// The list of items in the page.
  final List<DebtItem> items;

  /// The selection controller for the page.
  final SelectionController<DebtItem> selection;

  /// The callback to call when the user exits selection mode.
  final void Function() onSelectionEnd;

  /// The callback to call when some of the app's settings are changed.
  /// Only used when [personName] is null.
  final void Function()? onSettingsChanged;

  const EntryListAppBar({
    super.key,
    required this.items,
    required this.selection,
    required this.onSelectionEnd,
    this.personName,
    this.onSettingsChanged,
  });

  /// The preferred size of the app bar. Equal to [kToolbarHeight].
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  State<EntryListAppBar> createState() => _EntryListAppBarState();
}

class _EntryListAppBarState extends State<EntryListAppBar> {
  void _listener() => setState(() {});

  /// List of [ConfirmAction]s displayed on the app bar when the user is in selection mode.
  List<ConfirmAction> get _confirmActions => [
        if (widget.selection.every((p) => p.checked))
          ConfirmActions.uncheck
        else
          ConfirmActions.check,
        ConfirmActions.delete,
      ];

  /// Displays a dialog to edit the selected item.
  void _onEdit() => showDialog<DebtItem?>(
        context: context,
        builder: (BuildContext context) => EditDialog(
          item: widget.selection.first!,
          validator: widget.selection.first is Person
              ? (newItem) => newItem.text.isEmpty
                  ? 'Name cannot be empty!'
                  : newItem.text != widget.selection.first!.text &&
                          widget.items.any((i) => i.text == newItem.text)
                      ? 'Name already exists!'
                      : null
              : null,
        ),
      ).then((newItem) {
        if (newItem != null) people.replace(widget.selection.first!, newItem);
        widget.onSelectionEnd();
      });

  @override
  void initState() {
    super.initState();
    widget.selection.addListener(_listener);
  }

  @override
  void dispose() {
    widget.selection.removeListener(_listener);
    super.dispose();
  }

  Widget _buildAddButton() => IconButton(
        tooltip: 'Add entry',
        icon: const Icon(Symbols.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddEntryDialog(personName: widget.personName),
        ),
      );

  Widget _buildMenu() => MenuButton(onChanged: widget.onSettingsChanged);

  Widget _buildEditButton() => IconButton(
        tooltip: 'Edit',
        icon: const Icon(Symbols.edit),
        onPressed: _onEdit,
      );

  Widget _buildConfirmButton(ConfirmAction action) => ConfirmButton(
        action: action,
        items: widget.items,
        selection: widget.selection,
        onConfirm: (newPeople) {
          if (newPeople != null) {
            if (newPeople.isEmpty) {
              people.clearAll(widget.personName);
            } else {
              people.replaceAll(newPeople);
            }
            widget.onSelectionEnd();
          }
        },
      );

  Widget _buildExitSelectButton() => IconButton(
        icon: const Icon(Symbols.close),
        onPressed: widget.onSelectionEnd,
      );

  @override
  Widget build(BuildContext context) => AppBar(
        leading: widget.selection.any ? _buildExitSelectButton() : null,
        title: Text(
          widget.selection.any
              ? widget.selection.single
                  ? widget.selection.first is Person
                      ? widget.selection.first!.text
                      : '1 item'
                  : '${widget.selection.size} items'
              : widget.personName != null
                  ? widget.personName!
                  : 'Debt Tracker',
        ),
        actions: [
          if (widget.selection.any) ...[
            if (widget.selection.single) _buildEditButton(),
            for (final action in _confirmActions) _buildConfirmButton(action),
          ] else ...[
            _buildAddButton(),
            if (widget.personName == null)
              _buildMenu()
            else
              const SizedBox(width: 16),
          ],
        ],
      );
}
