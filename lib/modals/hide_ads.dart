import 'package:debt/config.dart';
import 'package:debt/modals/debt_dialog.dart';
import 'package:flutter/material.dart';

/// A dialog that allows to hide the ads of the app.
/// 
/// It explains that the ads are the only profit the developer gets from the app,
/// and that they can be hidden for free.
class HideAdsDialog extends StatelessWidget {
  const HideAdsDialog({super.key});

  @override
  Widget build(BuildContext context) => DebtDialog(
        title: 'Hide Ads (Free)',
        content: const Text(
          'You can hide all the ads of any of my apps with no cost at all. '
          'However, I would like you to consider keeping them '
          'as the very little money I get from showing them is my only profit for working on these apps.',
        ),
        action: 'Hide',
        onAction: () {
          DebtSettings.showAds = false;
          Navigator.of(context).pop(true);
        },
      );
}
