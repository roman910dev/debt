import 'package:currency_formatter/currency_formatter.dart';
import 'package:debt/config.dart';
import 'package:debt/scripts/validation_text_editing_controller.dart';
import 'package:debt/themes.dart';
import 'package:debt/tools.dart';
import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AmountFieldController extends ValidationTextEditingController {
  bool _valid = true;
  bool _positive = true;

  @override
  bool get valid => _valid;

  bool get positive => _positive;

  num? get modulus {
    try {
      String val = text.replaceAll(DebtSettings.currency.decimalSeparator, '.');
      final dynamic amount = evaluator.eval(Expression.parse(val), {});
      return amount != double.infinity && amount is num ? amount : null;
    } catch (_) {
      return null;
    }
  }

  num? get amount => modulus != null ? modulus! * (_positive ? 1 : -1) : null;

  void togglePositive() => _positive = !_positive;
}

class AmountField extends StatefulWidget {
  final AmountFieldController controller;
  final bool autofocus;
  final void Function()? onEditingComplete;

  const AmountField({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.onEditingComplete,
  });

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  void _onChanged(val) {
    try {
      if (val.trim() == '-') {
        widget.controller.togglePositive();
        widget.controller.text = '';
        widget.controller._valid = true;
      } else {
        final num? modulus = widget.controller.modulus;
        widget.controller._valid = modulus != null;
        if (modulus != null && modulus < 0) {
          widget.controller.togglePositive();
          widget.controller.text = widget.controller.text.replaceAll('-', '');
        }
      }
    } on Exception {
      widget.controller._valid = false;
    }
    setState(() {});
  }

  Widget _buildSignButton() => IconButton(
        icon: widget.controller._positive
            ? Icon(Symbols.add, color: DebtColors.of(context).accent)
            : Icon(Symbols.remove, color: DebtColors.of(context).error),
        iconSize: 16,
        color: widget.controller.text.isNotEmpty
            ? widget.controller.valid
                ? DebtColors.of(context).accent
                : DebtColors.of(context).error
            : DebtColors.of(context).text,
        padding: EdgeInsets.zero,
        onPressed: () => setState(() => widget.controller.togglePositive()),
      );

  Widget _buildTextField() => TextField(
        controller: widget.controller,
        onChanged: _onChanged,
        textAlign: TextAlign.left,
        autofocus: widget.autofocus,
        keyboardType: DebtSettings.calculatorEnabled
            ? null
            : const TextInputType.numberWithOptions(signed: true, decimal: true),
        cursorColor: widget.controller.valid && widget.controller.positive
            ? DebtColors.of(context).accent
            : DebtColors.of(context).error,
        decoration: DebtInputDecoration(
          context,
          hintText: DebtSettings.currency.symbol,
          prefixText: widget.controller.text.isNotEmpty &&
                  DebtSettings.currency.symbolSide == SymbolSide.left
              ? '${DebtSettings.currency.symbol} '
              : null,
          suffixText: widget.controller.text.isNotEmpty &&
                  DebtSettings.currency.symbolSide == SymbolSide.right
              ? DebtSettings.currency.symbol
              : null,
          valid: widget.controller.valid,
          filled: false,
        ),
        onEditingComplete: widget.onEditingComplete,
      );

  @override
  Widget build(BuildContext context) => Container(
        // vertical padding is to compensate for not having a label
        padding: const EdgeInsets.fromLTRB(0, 6, 8, 6),
        decoration: BoxDecoration(
          color: widget.controller.valid
              ? DebtColors.of(context).background
              : Theme.of(context).colorScheme.error.withOpacity(.1),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        child: Row(
          children: [
            _buildSignButton(),
            Expanded(child: _buildTextField()),
          ],
        ),
      );
}
