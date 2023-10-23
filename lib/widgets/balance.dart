import 'package:currency_formatter/currency_formatter.dart';
import 'package:debt/config.dart';
import 'package:debt/scripts/classes.dart';
import 'package:debt/themes.dart';
import 'package:debt/scripts/selection_controller.dart';
import 'package:flutter/material.dart';

/// A widget that displays the balance of the [selection] or the [items] if the first one is empty.
///
/// It is formatted using [DebtSettings.currency].
class Balance extends StatefulWidget {
  final SelectionController<DebtItem> selection;
  final List<DebtItem> items;
  const Balance({super.key, required this.selection, required this.items});

  @override
  State<Balance> createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  void _listener() => setState(() {});

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

  num get _balance =>
      (widget.selection.any ? widget.selection.selectedItems : widget.items)
          .balance;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            widget.selection.any ? 'Selected balance:' : 'Balance:',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              // fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            CurrencyFormatter.format(_balance, DebtSettings.currency),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _balance < 0
                  ? DebtColors.of(context).error
                  : DebtColors.of(context).accent,
            ),
          ),
          const SizedBox(width: 16),
        ],
      );
}
