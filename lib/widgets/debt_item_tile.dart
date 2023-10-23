import 'package:currency_formatter/currency_formatter.dart';
import 'package:debt/config.dart';
import 'package:debt/pages/entry_list/entry_list.dart';
import 'package:debt/scripts/classes.dart';
import 'package:debt/themes.dart';
import 'package:debt/tools.dart';
import 'package:debt/modals/confirm_action.dart';
import 'package:debt/scripts/selection_controller.dart';
import 'package:flutter/material.dart';

/// A tile that displays a [DebtItem].
class DebtItemTile extends StatefulWidget {
  /// The item to display.
  final DebtItem item;

  /// The selection controller of the page.
  /// Used to know if the item is selected.
  final SelectionController<DebtItem> selection;

  const DebtItemTile({super.key, required this.item, required this.selection});

  @override
  State<DebtItemTile> createState() => _DebtItemTileState();
}

class _DebtItemTileState extends State<DebtItemTile> {
  bool _selected = false;
  bool _selectionMode = false;

  void _listener() {
    if (mounted && _selected != widget.selection.isSelected(widget.item) ||
        _selectionMode != widget.selection.any) {
      _selected = widget.selection.isSelected(widget.item);
      _selectionMode = widget.selection.any;
      setState(() {});
    }
  }

  void _startSelection() => widget.selection
    ..clear()
    ..select(widget.item);

  bool get _enabled => !widget.item.checked;

  bool get _dismissible =>
      widget.item is Entry && !widget.item.checked && !_selectionMode;

  @override
  void initState() {
    super.initState();
    widget.selection.addListener(_listener..call());
  }

  @override
  void dispose() {
    widget.selection.removeListener(_listener);
    super.dispose();
  }

  Widget _buildTitle() => Text(
        widget.item.text,
        style: widget.item is Person
            ? TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _enabled
                    ? DebtColors.of(context).title
                    : DebtColors.of(context).disabled,
              )
            : TextStyle(
                fontSize: 16,
                color: _enabled
                    ? DebtColors.of(context).title
                    : DebtColors.of(context).disabled,
              ),
      );

  Widget _buildMoney(num money) => widget.item is Person && widget.item.checked
      ? const SizedBox()
      : Text(
          CurrencyFormatter.format(
            money,
            DebtSettings.currency,
            compact: money >= 100,
            decimal: 2,
          ),
          textAlign: TextAlign.end,
          style: TextStyle(
            color: _enabled
                ? money < 0
                    ? DebtColors.of(context).error
                    : DebtColors.of(context).accent
                : DebtColors.of(context).disabled,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        );

  Widget _buildDate() => Text(
        widget.item.date.toFormattedString(),
        style: TextStyle(
          color: _enabled
              ? DebtColors.of(context).text
              : DebtColors.of(context).disabled,
        ),
      );

  Widget _buildDismissibleBackground(DismissDirection direction) => ![
        DismissDirection.startToEnd,
        DismissDirection.endToStart,
      ].contains(direction)
          ? throw ''
              'Invalid direction: $direction. '
              'Only startToEnd and endToStart are allowed.'
          : Container(
              decoration: BoxDecoration(
                color: direction == DismissDirection.startToEnd
                    ? const Color(0xff222222)
                    : DebtColors.of(context).error,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              alignment: direction == DismissDirection.startToEnd
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              padding: const EdgeInsets.all(24),
              child: Icon(
                direction == DismissDirection.startToEnd
                    ? ConfirmActions.check.icon
                    : ConfirmActions.delete.icon,
                color: Colors.white,
              ),
            );

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(flex: 3, child: _buildTitle()),
              const SizedBox(width: 16),
              Flexible(flex: 2, child: _buildMoney(widget.item.money)),
            ],
          ),
          const SizedBox(height: 8),
          _buildDate(),
        ],
      ),
    );

    Widget tappable = _selectionMode
        ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.selection.toggle(widget.item),
              child: content,
            ),
          )
        : Material(
            color: Colors.transparent,
            child: InkWell(
              splashFactory: InkRipple.splashFactory,
              borderRadius: BorderRadius.circular(8),
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: widget.item is Person
                  ? () => delay(200).then(
                        (_) => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EntryList(widget.item.text),
                          ),
                        ),
                      )
                  : null,
              onLongPress: _startSelection,
              onSecondaryTap: () => delay(200).then((_) => _startSelection()),
              child: content,
            ),
          );

    Widget decoration = AnimatedContainer(
      key: Key(widget.item.toString()),
      duration: const Duration(milliseconds: 150),
      curve: Curves.ease,
      decoration: BoxDecoration(
        color: DebtColors.of(context).itemBG.withOpacity(_enabled ? 1 : .5),
        border: Border.all(
          color: _selected ? DebtColors.of(context).border : Colors.transparent,
          width: 2,
        ),
        borderRadius: _dismissible ? null : BorderRadius.circular(8),
      ),
      child: tappable,
    );

    return _dismissible
        ? ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Dismissible(
              key: Key(widget.item.toString()),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.startToEnd) {
                  people.setChecked(widget.item, true);
                }
              },
              confirmDismiss: (DismissDirection direction) async {
                if (direction == DismissDirection.startToEnd) return true;

                if (direction == DismissDirection.endToStart) {
                  final result = await showDialog(
                    context: context,
                    builder: (context) => ConfirmDialog(
                      action: ConfirmActions.delete,
                      items: [widget.item],
                      selection: SelectionController({widget.item}),
                    ),
                  );
                  if (result != null) {
                    people.deleteEntry(widget.item as Entry);
                    return true;
                  }
                }
                return null;
              },
              // resizeDuration: null,
              background:
                  _buildDismissibleBackground(DismissDirection.startToEnd),
              secondaryBackground:
                  _buildDismissibleBackground(DismissDirection.endToStart),
              child: decoration,
            ),
          )
        : decoration;
  }
}
