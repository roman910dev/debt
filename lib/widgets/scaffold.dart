import 'package:debt/config.dart';
import 'package:flutter/material.dart';

class DebtScaffold extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget body;

  const DebtScaffold({
    super.key,
    this.title,
    this.actions,
    this.leading,
    required this.body,
    required this.appBar,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: appBar ,
        body: body,
        backgroundColor: DebtSettings.theme == ThemeMode.light
            ? Colors.white
            : Theme.of(context).scaffoldBackgroundColor,
      );
}
