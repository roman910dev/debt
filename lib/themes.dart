import 'package:debt/config.dart';
import 'package:flutter/material.dart';

/// The default text styles used in the app themes.
TextStyle _defaultStyle({Color? color, FontWeight? fontWeight}) => TextStyle(
      fontFamily: 'Roboto',
      fontFamilyFallback: const ['Helvetica', 'Arial', 'sans-serif'],
      color: color,
      fontWeight: fontWeight,
      // iOS Web workaround
      decoration: DebtEnv.iOSWeb ? TextDecoration.underline : null,
      decorationColor: DebtEnv.iOSWeb ? Colors.white.withOpacity(.01) : null,
    );

/// The light theme of the app.
final ThemeData lightTheme = ThemeData(
  // fontFamily: iOSWeb
  //     ? '--apple-system'
  //     : null,
  useMaterial3: false,
  cardColor: Colors.white,
  primaryTextTheme: TextTheme(
    displayLarge: _defaultStyle(),
    displayMedium: _defaultStyle(),
    displaySmall: _defaultStyle(),
    headlineMedium: _defaultStyle(),
    headlineSmall: _defaultStyle(),
    titleLarge: _defaultStyle(color: Colors.green, fontWeight: FontWeight.w500),
    titleMedium: _defaultStyle(),
    titleSmall: _defaultStyle(),
    bodyLarge: _defaultStyle(),
    bodyMedium: _defaultStyle(),
    bodySmall: _defaultStyle(),
    labelLarge: _defaultStyle(),
    labelSmall: _defaultStyle(),
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
    displayLarge: _defaultStyle(),
    displayMedium: _defaultStyle(),
    displaySmall: _defaultStyle(),
    headlineMedium: _defaultStyle(),
    headlineSmall: _defaultStyle(),
    titleLarge: _defaultStyle(fontWeight: FontWeight.w500),
    titleMedium: _defaultStyle(),
    titleSmall: _defaultStyle(),
    bodyLarge: _defaultStyle(fontWeight: FontWeight.w500),
    bodyMedium: _defaultStyle(),
    bodySmall: _defaultStyle(),
    labelLarge: _defaultStyle(fontWeight: FontWeight.w500),
    labelSmall: _defaultStyle(),
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

/// The dark theme of the app.
final ThemeData darkTheme = ThemeData(
  // fontFamily: iOSWeb
  //     ? '-apple-system'
  //     : null,
  useMaterial3: false,
  primaryTextTheme: TextTheme(
    displayLarge: _defaultStyle(),
    displayMedium: _defaultStyle(),
    displaySmall: _defaultStyle(),
    headlineMedium: _defaultStyle(),
    headlineSmall: _defaultStyle(),
    titleLarge:
        _defaultStyle(color: Colors.green[200], fontWeight: FontWeight.w500),
    titleMedium: _defaultStyle(),
    titleSmall: _defaultStyle(),
    bodyLarge: _defaultStyle(),
    bodyMedium: _defaultStyle(),
    bodySmall: _defaultStyle(),
    labelLarge: _defaultStyle(),
    labelSmall: _defaultStyle(),
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
    displayLarge: _defaultStyle(),
    displayMedium: _defaultStyle(),
    displaySmall: _defaultStyle(),
    headlineMedium: _defaultStyle(),
    headlineSmall: _defaultStyle(),
    titleLarge: _defaultStyle(fontWeight: FontWeight.w500),
    titleMedium: _defaultStyle(),
    titleSmall: _defaultStyle(),
    bodyLarge: _defaultStyle(fontWeight: FontWeight.w500),
    bodyMedium: _defaultStyle(),
    bodySmall: _defaultStyle(),
    labelLarge: _defaultStyle(fontWeight: FontWeight.w500),
    labelSmall: _defaultStyle(),
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

/// An abstract class used to get some custom colors for the app,
/// depending on the current theme.
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

  static DebtColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? DebtDarkColors(context)
          : DebtLightColors(context);
}

/// The custom dark colors of the app.
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

/// The custom light colors of the app.
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
