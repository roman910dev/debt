import 'package:debt/config.dart';
import 'package:debt/widgets/debt_edit_dialog.dart';
import 'package:flutter/material.dart';

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
