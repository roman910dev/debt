import 'package:debt/main.dart';
import 'package:flutter/material.dart';

InputDecoration filledInputDecoration(
  String labelText,
  BuildContext context, {
  IconData icon,
  Widget suffix,
  bool valid = true,
  String prefixText,
  String errorText,
  String hintText,
  bool underline = false,
  bool hidden,
  bool filled = true,
  Function(bool) onHide,
}) =>
    InputDecoration(
      // labelText: label,
      // labelStyle: TextStyle(color: valid ? null : Theme.of(context).errorColor),
      label: labelText == null
          ? null
          : Text(
              labelText,
              style:
                  TextStyle(color: valid ? null : Theme.of(context).errorColor),
            ),
      filled: filled,
      fillColor: valid
          ? bgColor(context)
          : Theme.of(context).errorColor.withOpacity(.1),
      hoverColor: Colors.transparent,
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              color: valid ? null : Theme.of(context).errorColor,
            ),
      border: const UnderlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(6))),
      errorText: valid ? null : errorText,
      errorStyle: TextStyle(color: Theme.of(context).errorColor),
      focusedBorder: UnderlineInputBorder(
          borderSide: underline
              ? BorderSide(
                  width: 2,
                  color: valid
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).errorColor)
              : BorderSide.none,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6), topRight: Radius.circular(6))),
      prefixText: prefixText,
      suffix: suffix ??
          (hidden != null
              ? InkWell(
                  child: hidden
                      ? const Icon(Icons.visibility_rounded)
                      : const Icon(Icons.visibility_off_rounded),
                  onTap: onHide == null ? null : () => onHide(!hidden),
                )
              : null),
      hintText: hintText,
    );
