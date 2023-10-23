import 'dart:io';

import 'package:collection/collection.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:debt/scripts/classes.dart';
import 'package:expressions/expressions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An [ExpressionEvaluator] that can be used
/// to evaluate mathematical expressions throughout the app.
const ExpressionEvaluator evaluator = ExpressionEvaluator();

/// The controller of the people list.
final PeopleController people = PeopleController();

/// An abstract class containing some immutable data
/// about the environment where the app is running.
abstract class DebtEnv {
  /// Whether the app is running in development mode.
  /// This is defined at compile time with the `devMode` flag.
  static const bool devMode = bool.fromEnvironment('devMode');

  /// Whether the app is running on Android or iOS.
  ///
  /// It is evaluated as `!kIsWeb && (Platform.isAndroid || Platform.isIOS)`.
  static final bool isMobile =
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Whether the app is running on Web on an iOS device.
  ///
  /// It is evaluated as `kIsWeb && defaultTargetPlatform == TargetPlatform.iOS`.
  static final bool iOSWeb =
      kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}

/// A class containing some settings of the app.
abstract class DebtSettings {
  /// Whether ads should be shown.
  static bool showAds = true;

  static CurrencyFormat _currency = CurrencyFormat.usd;

  /// The currency used in the app.
  static CurrencyFormat get currency => _currency;

  static set currency(CurrencyFormat value) {
    _currency = value;
    _systemCurrency = false;
  }

  static bool _systemCurrency = false;

  /// Whether the system currency should be used.
  ///
  /// When this is true [currency] is equal to [CurrencyFormat.local].
  static bool get systemCurrency => _systemCurrency;

  /// Sets the currency to the system one.
  ///
  /// This is done by setting [currency] to [CurrencyFormat.local]
  /// and setting [systemCurrency] to `true`.
  static void setSystemCurrency() {
    _systemCurrency = true;
    _currency = CurrencyFormat.local ?? CurrencyFormat.usd;
  }

  /// Whether the calculator input is enabled.
  static bool calculatorInput = false;

  static final ValueNotifier<ThemeMode> _theme =
      ValueNotifier(ThemeMode.system);

  /// A [ValueNotifier] with [theme] value.
  static ValueNotifier<ThemeMode> get themeNotifier => _theme;

  /// The theme of the app.
  ///
  /// Use [themeNotifier] to listen to changes.
  static ThemeMode get theme => _theme.value;

  static set theme(ThemeMode value) => _theme.value = value;

  /// Loads the settings from [SharedPreferences].
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // load currency
    final String symbol = prefs.getString('currencySymbol') ?? '';
    if (symbol.isEmpty) {
      setSystemCurrency();
    } else {
      currency = CurrencyFormat.fromSymbol(symbol) ??
          CurrencyFormat(
            symbol: symbol.substring(1),
            symbolSide: SymbolSide.values.firstWhereOrNull(
                  (s) => s.name[0] == symbol[0],
                ) ??
                SymbolSide.left,
          );
    }

    theme = ThemeMode.values.firstWhereOrNull(
          (t) => t.name == prefs.getString('theme'),
        ) ??
        ThemeMode.system;

    // load ads
    showAds = prefs.getBool('showAds') ?? true;

    // load calculator
    calculatorInput = prefs.getBool('calc') ?? false;
  }

  /// Saves the settings to [SharedPreferences].
  static Future<void> save() async => (await SharedPreferences.getInstance())
    ..setString('theme', theme.name)
    ..setBool('showAds', showAds)
    ..setBool('calc', calculatorInput)
    ..setString(
      'currencySymbol',
      systemCurrency
          ? ''
          : CurrencyFormatter.majors.values.contains(currency)
              ? currency.symbol
              : '${currency.symbolSide.name[0]}${currency.symbol}',
    );
}
