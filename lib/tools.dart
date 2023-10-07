import 'package:debt/themes.dart';
import 'package:flutter/material.dart';

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
                  style: TextStyle(color: valid ? null : DebtColors.of(context).error),
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
          border: const UnderlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          errorText: valid ? null : errorText,
          errorStyle: TextStyle(color: DebtColors.of(context).error),
        );
}

Future<void> delay(int milliseconds) => Future.delayed(Duration(milliseconds: milliseconds));

extension DebtDateTime on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
  static DateTime fromSecondsSinceEpoch(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

  String toFormattedString() => '$day/$month/$year';

  static DateTime parse(String date) => DateTime(
        int.parse(date.split('/')[2]),
        int.parse(date.split('/')[1]),
        int.parse(date.split('/')[0]),
      );

  static DateTime? tryParse(String date) {
    try {
      return parse(date);
    } catch (_) {
      return null;
    }
  }
}

extension DebtString on String {
  String toFirstUpperCase() => '${this[0].toUpperCase()}${substring(1)}';
}
