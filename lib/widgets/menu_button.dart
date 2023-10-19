import 'dart:convert';

import 'package:debt/config.dart';
import 'package:debt/scripts/classes.dart';
import 'package:debt/widgets/about_sheet.dart';
import 'package:debt/widgets/calculator_dialog.dart';
import 'package:debt/widgets/currency_dialog.dart';
import 'package:debt/widgets/hide_ads_dialog.dart';
import 'package:debt/widgets/theme_dialog.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MenuOption { theme, currency, calculator, ads, about, prefs }

class MenuButton extends StatelessWidget {
  final void Function()? onChanged;
  const MenuButton({super.key, this.onChanged});

  Future<bool?> _handleAds(BuildContext context) async {
    if (DebtSettings.showAds) {
      return showDialog(
        context: context,
        builder: (context) => const HideAdsDialog(),
      );
    } else {
      DebtSettings.showAds = true;
    }
    return true;
  }

  Future<bool?> _showPrefs(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return null;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SelectableText(
          [
            'people:\n${jsonEncode(people.people.toJson())}',
            for (final key in prefs.getKeys()) '$key:\n${prefs.get(key)}'
          ].join('\n\n'),
        ),
      ),
    );
    return null;
  }

  @override
  Widget build(BuildContext context) => PopupMenuButton<MenuOption>(
        itemBuilder: (context) => [
          const PopupMenuItem(value: MenuOption.theme, child: Text('Set theme')),
          const PopupMenuItem(value: MenuOption.currency, child: Text('Set currency')),
          const PopupMenuItem(value: MenuOption.calculator, child: Text('Calculator input')),
          if (DebtData.isMobile) ...[
            PopupMenuItem(
              value: MenuOption.ads,
              child: Text(DebtSettings.showAds ? 'Hide ads (free)' : 'Show ads'),
            ),
          ],
          const PopupMenuItem(value: MenuOption.about, child: Text('About')),
          if (devMode) const PopupMenuItem(value: MenuOption.prefs, child: Text('[DEV] Prefs')),
        ],
        onSelected: (value) async {
          final Future<bool?> changed = switch (value) {
            MenuOption.theme => showDialog(
                context: context,
                builder: (context) => const ThemeDialog(),
              ),
            MenuOption.currency => showDialog(
                context: context,
                builder: (context) => const CurrencyDialog(),
              ),
            MenuOption.calculator => showDialog(
                context: context,
                builder: (context) => CalculatorDialog(),
              ),
            MenuOption.ads => _handleAds(context),
            MenuOption.about => showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => const AboutSheet(),
              ),
            MenuOption.prefs => _showPrefs(context),
          };
          if (await changed == true) onChanged?.call();
        },
        icon: const Icon(Symbols.more_vert),
      );
}
