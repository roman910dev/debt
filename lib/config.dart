import 'dart:io';

import 'package:collection/collection.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:debt/scripts/classes.dart';
import 'package:expressions/expressions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const ExpressionEvaluator evaluator = ExpressionEvaluator();
final PeopleController people = PeopleController();

abstract class DebtData {
  static final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static final bool iOSWeb = kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}

abstract class DebtSettings {
  static bool showAds = true;

  static CurrencyFormat currency = CurrencyFormat.usd;
  static String? locale;
  static bool get localCurrency => locale != null;

  static bool calculatorEnabled = false;

  static final ValueNotifier<ThemeMode> _theme = ValueNotifier(ThemeMode.system);
  static ValueNotifier<ThemeMode> get themeNotifier => _theme;
  static ThemeMode get theme => _theme.value;
  static set theme(ThemeMode value) => _theme.value = value;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // load currency
    final String symbol = prefs.getString('currencySymbol') ?? '';
    if (symbol.isEmpty) {
      if (DebtData.isMobile) {
        currency = CurrencyFormat.local ?? CurrencyFormat.usd;
        locale = Platform.localeName;
      }
    } else {
      currency = CurrencyFormat.fromSymbol(symbol) ??
          CurrencyFormat(
            symbol: symbol.substring(1),
            symbolSide: symbol.startsWith('l') ? SymbolSide.left : SymbolSide.right,
          );
    }

    theme = ThemeMode.values.firstWhereOrNull((t) => t.name == prefs.getString('theme')) ??
        ThemeMode.system;

    // load ads
    showAds = prefs.getBool('showAds') ?? true;

    // load calculator
    calculatorEnabled = prefs.getBool('calc') ?? false;
  }

  static Future<void> save() async => (await SharedPreferences.getInstance())
    ..setString('theme', theme.name)
    ..setBool('showAds', showAds)
    ..setBool('calc', calculatorEnabled)
    ..setString(
      'currencySymbol',
      CurrencyFormatter.majors.values.contains(currency)
          ? localCurrency
              ? ''
              : currency.symbol
          : '${currency.symbolSide == SymbolSide.left ? 'l' : 'r'}${currency.symbol}',
    );
}
