import 'dart:convert';

import 'package:debt/config.dart';
import 'package:debt/scripts/classes.dart';
import 'package:debt/modals/about.dart';
import 'package:debt/modals/calculator_input_settings.dart';
import 'package:debt/modals/currency_settings.dart';
import 'package:debt/modals/hide_ads.dart';
import 'package:debt/modals/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The options of the menu button.
///
/// [prefs] is only available in dev mode.
enum MenuOption { theme, currency, calculator, ads, about, prefs }

/// A button that opens a menu with options ([MenuOption]s).
///
/// Some of them are app settings.
/// When one of these is changed, the [onChanged] callback is called.
class MenuButton extends StatelessWidget {
  /// The callback called when a setting is changed.
  /// e.g. when the theme is changed.
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
            for (final key in prefs.getKeys()) '$key:\n${prefs.get(key)}',
          ].join('\n\n'),
        ),
      ),
    );
    return null;
  }

  @override
  Widget build(BuildContext context) => PopupMenuButton<MenuOption>(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: MenuOption.theme,
            child: Text('Set theme'),
          ),
          const PopupMenuItem(
            value: MenuOption.currency,
            child: Text('Set currency'),
          ),
          const PopupMenuItem(
            value: MenuOption.calculator,
            child: Text('Calculator input'),
          ),
          if (DebtEnv.isMobile) ...[
            PopupMenuItem(
              value: MenuOption.ads,
              child: Text(
                DebtSettings.showAds ? 'Hide ads (free)' : 'Show ads',
              ),
            ),
          ],
          const PopupMenuItem(
            value: MenuOption.about,
            child: Text('About'),
          ),
          if (DebtEnv.devMode)
            const PopupMenuItem(
              value: MenuOption.prefs,
              child: Text('[DEV] Prefs'),
            ),
        ],
        onSelected: (value) async {
          final Future<bool?> changed = switch (value) {
            MenuOption.theme => showDialog(
                context: context,
                builder: (context) => const ThemeSettingsDialog(),
              ),
            MenuOption.currency => showDialog(
                context: context,
                builder: (context) => const CurrencyDialog(),
              ),
            MenuOption.calculator => showDialog(
                context: context,
                builder: (context) => CalculatorInputSettingsDialog(),
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
