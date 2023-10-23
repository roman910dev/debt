import 'package:currency_formatter/currency_formatter.dart';
import 'package:debt/config.dart';
import 'package:debt/tools.dart';
import 'package:debt/modals/debt_dialog.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A widget that allows the user to set a custom currency format.
/// This widget is used in the [CurrencyDialog].
///
/// The user can set the currency symbol and the side of the symbol, and a preview is shown.
class _CustomCurrency extends StatelessWidget {
  final ValueNotifier<CurrencyFormat?> controller;
  const _CustomCurrency(this.controller);

  void _onChanged({String? symbol, SymbolSide? side}) {
    // no need to call `setState` because parent already has a listener
    controller.value = CurrencyFormat(
      symbol: symbol ?? controller.value!.symbol,
      symbolSide: side ?? controller.value!.symbolSide,
    );
  }

  Widget _buildExample() => Text(
        CurrencyFormatter.format(
          9999.99,
          controller.value!,
        ),
      );

  Widget _buildSymbol(BuildContext context) => TextFormField(
        initialValue: controller.value!.symbol,
        // To match dropdown height
        style: const TextStyle(height: 1.5),
        decoration: DebtInputDecoration(
          context,
          labelText: 'Symbol',
        ),
        onChanged: (value) => _onChanged(symbol: value),
      );

  Widget _buildSide(BuildContext context) => DropdownButtonFormField(
        decoration: DebtInputDecoration(context, labelText: 'Side'),
        value: controller.value!.symbolSide,
        items: [
          for (final side in SymbolSide.values)
            DropdownMenuItem(
              value: side,
              child: Text(side.name),
            ),
        ],
        onChanged: (value) {
          if (value != null) _onChanged(side: value);
        },
      );

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _buildExample(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSymbol(context)),
              const SizedBox(width: 16),
              Expanded(child: _buildSide(context)),
            ],
          ),
        ],
      );
}

/// A widget that allows the user to select a currency format.
///
/// The user can select from a list of predefined currency formats, or set a custom format.
class _CurrencySettings extends StatefulWidget {
  final ValueNotifier<CurrencyFormat?> controller;
  const _CurrencySettings(this.controller);

  @override
  State<_CurrencySettings> createState() => _CurrencySettingsState();
}

class _CurrencySettingsState extends State<_CurrencySettings> {
  bool _customMode = false;

  void _listener() => setState(() {});

  void _setCustomMode() {
    widget.controller.value ??= CurrencyFormat.local ?? CurrencyFormat.usd;
    setState(() => _customMode = true);
  }

  @override
  void initState() {
    widget.controller.addListener(_listener);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  Widget _buildCustomCurrencyButton() => InkWell(
        splashFactory: InkRipple.splashFactory,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          leading: const Icon(Symbols.add),
          title: const Text('Custom'),
          onTap: _setCustomMode,
        ),
      );

  Widget _radioTile(String title, CurrencyFormat? value) => RadioListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: Text(title),
        value: value,
        groupValue: widget.controller.value,
        activeColor: Theme.of(context).colorScheme.secondary,
        onChanged: (val) => setState(() => widget.controller.value = val),
      );

  Widget _buildSystemOption() => _radioTile('System', null);

  Widget _buildCurrencyOption(int i) => _radioTile(
        '${CurrencyFormatter.majorSymbols.keys.elementAt(i).toUpperCase()}  '
        '[ ${CurrencyFormatter.majorSymbols.values.elementAt(i)} ]',
        CurrencyFormatter.majors.values.elementAt(i),
      );

  @override
  Widget build(BuildContext context) => _customMode
      ? _CustomCurrency(widget.controller)
      : Expanded(
          child: ListView.builder(
            itemCount: CurrencyFormatter.majors.length + 2,
            itemBuilder: (context, i) => i == 0
                ? _buildCustomCurrencyButton()
                : i == 1
                    ? _buildSystemOption()
                    : _buildCurrencyOption(i - 2),
          ),
        );
}

/// A dialog that allows the user to select a currency format.
///
/// The user can select from a list of predefined currency formats, or set a custom format.
///
/// If the user selects a format, [DebtSettings.currency] and [DebtSettings.locale] are set,
/// and the dialog pops with `true`. Otherwise, the dialog pops with `null`.
class CurrencyDialog extends StatelessWidget {
  const CurrencyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<CurrencyFormat?> controller = ValueNotifier(
      DebtSettings.systemCurrency ? null : DebtSettings.currency,
    );
    return DebtDialog(
      maxWidth: 480,
      title: 'Select currency',
      content: _CurrencySettings(controller),
      action: 'Save',
      onAction: () {
        if (controller.value == null) {
          DebtSettings.setSystemCurrency();
        } else {
          DebtSettings.currency = controller.value!;
        }
        Navigator.of(context).pop(true);
      },
    );
  }
}
