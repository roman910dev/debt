import 'dart:io';

import 'package:currency_formatter/currency_formatter.dart';
import 'package:debt/config.dart';
import 'package:debt/tools.dart';
import 'package:debt/widgets/debt_edit_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class _CustomCurrency extends StatefulWidget {
  final void Function(CurrencyFormat)? onChanged;
  const _CustomCurrency({this.onChanged});

  @override
  State<_CustomCurrency> createState() => __CustomCurrencyState();
}

class __CustomCurrencyState extends State<_CustomCurrency> {
  String _symbol = DebtSettings.currency.symbol;
  SymbolSide _side = DebtSettings.currency.symbolSide;

  void _onChanged(void Function() callback) {
    setState(callback);
    widget.onChanged?.call(CurrencyFormat(symbol: _symbol, symbolSide: _side));
  }

  Widget _buildExample() => Text(
        CurrencyFormatter.format(
          9999.99,
          CurrencyFormat(symbol: _symbol, symbolSide: _side),
        ),
      );

  Widget _buildSymbol() => TextFormField(
        initialValue: _symbol,
        // To match dropdown height
        style: const TextStyle(height: 1.5),
        decoration: DebtInputDecoration(context, labelText: 'Symbol',),
        onChanged: (value) => _onChanged(() => _symbol = value),
      );

  Widget _buildSide() => DropdownButtonFormField(
        decoration: DebtInputDecoration(context, labelText: 'Side'),
        value: _side,
        items: [
          for (final side in SymbolSide.values)
            DropdownMenuItem(
              value: side,
              child: Text(side.name),
            ),
        ],
        onChanged: (value) {
          if (value != null) _onChanged(() => _side = value);
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
              Expanded(child: _buildSymbol()),
              const SizedBox(width: 16),
              Expanded(child: _buildSide()),
            ],
          ),
        ],
      );
}

class CurrencyDialog extends StatelessWidget {
  const CurrencyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    CurrencyFormat? option = DebtSettings.localCurrency ? null : DebtSettings.currency;
    CurrencyFormat? customOption;
    bool customCurrency = false;
    return DebtDialog(
      title: 'Select currency',
      content: StatefulBuilder(
        builder: (context, setState) {
          // num bannerHeight = bannerAd == null ? 0 : bannerAd!.size.height;
          num bannerHeight = 0;
          if (!customCurrency) {
            return Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - bannerHeight - 320,
              ),
              child: ListView.builder(
                itemCount: CurrencyFormatter.majors.length + 2,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return InkWell(
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        leading: const Icon(Symbols.add),
                        title: const Text('Custom'),
                        onTap: () => setState(() => customCurrency = true),
                      ),
                    );
                  } else {
                    if (kIsWeb && i == 1) return Container();

                    return RadioListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      title: i == 1
                          ? const Text('System')
                          : Text(CurrencyFormatter.majorSymbols.values.elementAt(i - 2)),
                      value: i == 1 ? null : CurrencyFormatter.majors.values.elementAt(i - 2),
                      groupValue: option,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (val) => setState(() => option = val),
                    );
                  }
                },
              ),
            );
          } else {
            return _CustomCurrency(
              onChanged: (custom) => customOption = custom,
            );
          }
        },
      ),
      action: 'Save',
      onAction: () {
        if (customOption == null) {
          if (option == null) {
            DebtSettings.currency =
                CurrencyFormat.local ?? CurrencyFormat.usd;
            DebtSettings.locale = Platform.localeName;
          } else {
            DebtSettings.currency = option!;
            DebtSettings.locale = null;
          }
        } else {
          DebtSettings.currency = customOption!;
          DebtSettings.locale = null;
        }
        Navigator.of(context).pop(true);
      },
    );
  }
}
