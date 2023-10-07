import 'package:flutter/material.dart';

TextStyle _safariStyle({Color? color, FontWeight? fontWeight}) => TextStyle(
      decoration: TextDecoration.underline,
      decorationColor: Colors.white.withOpacity(.01),
      fontFamily: 'Roboto',
      fontFamilyFallback: const ['Helvetica', 'Arial', 'sans-serif'],
      color: color,
      fontWeight: fontWeight,
    );

ThemeData lightTheme = ThemeData(
  // fontFamily: iOSWeb
  //     ? '--apple-system'
  //     : null,
  cardColor: Colors.white,
  primaryTextTheme: TextTheme(
    displayLarge: _safariStyle(),
    displayMedium: _safariStyle(),
    displaySmall: _safariStyle(),
    headlineMedium: _safariStyle(),
    headlineSmall: _safariStyle(),
    titleLarge: _safariStyle(color: Colors.green, fontWeight: FontWeight.w500),
    titleMedium: _safariStyle(),
    titleSmall: _safariStyle(),
    bodyLarge: _safariStyle(),
    bodyMedium: _safariStyle(),
    bodySmall: _safariStyle(),
    labelLarge: _safariStyle(),
    labelSmall: _safariStyle(),
  ),
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(
      color: Colors.green,
      fontSize: 20,
      letterSpacing: 0.15,
      fontWeight: FontWeight.w500,
    ),
    iconTheme: IconThemeData(color: Colors.green),
    color: Colors.white,
  ),
  textTheme: TextTheme(
    displayLarge: _safariStyle(),
    displayMedium: _safariStyle(),
    displaySmall: _safariStyle(),
    headlineMedium: _safariStyle(),
    headlineSmall: _safariStyle(),
    titleLarge: _safariStyle(fontWeight: FontWeight.w500),
    titleMedium: _safariStyle(),
    titleSmall: _safariStyle(),
    bodyLarge: _safariStyle(fontWeight: FontWeight.w500),
    bodyMedium: _safariStyle(),
    bodySmall: _safariStyle(),
    labelLarge: _safariStyle(fontWeight: FontWeight.w500),
    labelSmall: _safariStyle(),
  ),
  primaryIconTheme: const IconThemeData(color: Colors.green),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.green,
    selectionHandleColor: Colors.green,
    selectionColor: Colors.green,
  ),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
      .copyWith(secondary: Colors.green)
      .copyWith(error: Colors.red),
);

ThemeData darkTheme = ThemeData(
  // fontFamily: iOSWeb
  //     ? '-apple-system'
  //     : null,
  primaryTextTheme: TextTheme(
    displayLarge: _safariStyle(),
    displayMedium: _safariStyle(),
    displaySmall: _safariStyle(),
    headlineMedium: _safariStyle(),
    headlineSmall: _safariStyle(),
    titleLarge: _safariStyle(color: Colors.green[200], fontWeight: FontWeight.w500),
    titleMedium: _safariStyle(),
    titleSmall: _safariStyle(),
    bodyLarge: _safariStyle(),
    bodyMedium: _safariStyle(),
    bodySmall: _safariStyle(),
    labelLarge: _safariStyle(),
    labelSmall: _safariStyle(),
  ),
  appBarTheme: AppBarTheme(
    titleTextStyle: TextStyle(
      color: Colors.green[200],
      fontSize: 20,
      letterSpacing: 0.15,
      fontWeight: FontWeight.w500,
    ),
    iconTheme: IconThemeData(color: Colors.green[200]),
  ),
  textTheme: TextTheme(
    displayLarge: _safariStyle(),
    displayMedium: _safariStyle(),
    displaySmall: _safariStyle(),
    headlineMedium: _safariStyle(),
    headlineSmall: _safariStyle(),
    titleLarge: _safariStyle(fontWeight: FontWeight.w500),
    titleMedium: _safariStyle(),
    titleSmall: _safariStyle(),
    bodyLarge: _safariStyle(fontWeight: FontWeight.w500),
    bodyMedium: _safariStyle(),
    bodySmall: _safariStyle(),
    labelLarge: _safariStyle(fontWeight: FontWeight.w500),
    labelSmall: _safariStyle(),
  ),
  primaryIconTheme: IconThemeData(color: Colors.green[200]),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.green[200],
    selectionHandleColor: Colors.green[200],
    selectionColor: Colors.green[200],
  ),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: MaterialColor(Colors.green[200]!.value, const {}),
    accentColor: Colors.green[200],
    brightness: Brightness.dark,
    errorColor: Colors.red[200],
    cardColor: const Color(0xff404040),
  ).copyWith(error: Colors.red[200]),
);

abstract class DebtColors {
  BuildContext get _context;

  Color get border;
  Color get background;
  Color get itemBG;
  Color get title => Theme.of(_context).textTheme.titleSmall!.color!;
  Color get text => Theme.of(_context).textTheme.bodySmall!.color!;
  Color get disabled => Theme.of(_context).disabledColor;
  Color get error => Theme.of(_context).colorScheme.error;
  Color get accent => Theme.of(_context).colorScheme.secondary;

  static DebtColors of(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? DebtDarkColors(context)
      : DebtLightColors(context);
}

class DebtDarkColors extends DebtColors {
  @override
  final BuildContext _context;

  @override
  final Color border = Colors.white60;
  @override
  final Color background = Colors.black.withOpacity(.1);
  @override
  Color get itemBG => Theme.of(_context).cardColor;

  DebtDarkColors(BuildContext context) : _context = context;
}

class DebtLightColors extends DebtColors {
  @override
  final BuildContext _context;

  @override
  final Color border = Colors.black54;
  @override
  final Color background = Colors.black.withOpacity(.05);
  @override
  final Color itemBG = const Color(0xfff2f2f2);

  DebtLightColors(BuildContext context) : _context = context;
}
