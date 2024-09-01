import 'package:debt/themes.dart';
import 'package:flutter/material.dart';

const _hiddenBorder = UnderlineInputBorder(
  borderSide: BorderSide.none,
  borderRadius: BorderRadius.all(Radius.circular(6)),
);

/// The input decoration used across the app.
class DebtInputDecoration extends InputDecoration {
  DebtInputDecoration(
    BuildContext context, {
    String? labelText,
    IconData? icon,
    super.filled = true,
    bool valid = true,
    super.prefixText,
    super.suffixText,
    String? errorText,
    super.hintText,
  }) : super(
          label: labelText == null
              ? null
              : Text(
                  labelText,
                  style: TextStyle(
                    color: valid ? null : DebtColors.of(context).error,
                  ),
                ),
          fillColor: valid
              ? DebtColors.of(context).background
              : DebtColors.of(context).error.withOpacity(.1),
          hoverColor: Colors.transparent,
          prefixIcon: icon == null
              ? null
              : Icon(
                  icon,
                  color: valid ? null : DebtColors.of(context).error,
                ),
          border: _hiddenBorder,
          focusedBorder: _hiddenBorder,
          errorText: valid ? null : errorText,
          errorStyle: TextStyle(color: DebtColors.of(context).error),
        );
}

/// A delay of [milliseconds].
///
/// Works as an alias for `Future.delayed(Duration(milliseconds: milliseconds))`.
Future<void> delay(int milliseconds) =>
    Future.delayed(Duration(milliseconds: milliseconds));

extension DebtDateTime on DateTime {
  /// `millisecondsSinceEpoch ~/ 1000`.
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  /// `DateTime.fromMillisecondsSinceEpoch(seconds * 1000)`.
  static DateTime fromSecondsSinceEpoch(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

  /// DD/MM/YYYY.
  String toFormattedString() => ''
      '${day.toString().padLeft(2, '0')}/'
      '${month.toString().padLeft(2, '0')}/'
      '${year.toString().padLeft(4, '0')}';

  /// Parses a string in the format DD/MM/YYYY.
  static DateTime parse(String date) => DateTime(
        int.parse(date.split('/')[2]),
        int.parse(date.split('/')[1]),
        int.parse(date.split('/')[0]),
      );

  /// Tries to parse a string in the format DD/MM/YYYY.
  /// If it fails, `null` is returned.
  static DateTime? tryParse(String date) {
    try {
      return parse(date);
    } catch (_) {
      return null;
    }
  }
}

extension DebtString on String {
  /// Returns the string with the first letter capitalized.
  String toFirstUpperCase() => '${this[0].toUpperCase()}${substring(1)}';
}

/// A controller that manages a boolean value.
class BoolController extends ChangeNotifier {
  bool _value;

  BoolController([this._value = false]);

  bool get value => _value;

  set value(bool newValue) {
    _value = newValue;
    notifyListeners();
  }

  void toggle() => value = !value;
}
