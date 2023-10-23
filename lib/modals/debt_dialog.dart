import 'package:debt/themes.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A reusable widget that allows to easily create dialogs marking this app's dialog style.
///
/// It has a [title], the [content], and two buttons: a cancel one and the [action] button.
///
/// By default, the action button is an 'Ok' button and does nothing.
/// This behavior can be changed by passing an [action], which will change the text of the button,
/// and an [onAction] callback, which will be called when the button is pressed.
///
/// The cancel button has an [Symbols.close] icon and the action button has a [Symbols.check] icon,
/// they can be hidden by setting [showActionIcons] to false.
class DebtDialog extends StatelessWidget {
  /// The title of the dialog.
  final String title;

  /// The text of the action button.
  final String action;

  /// The callback called when the action button is pressed.
  final void Function()? onAction;

  /// Whether to show the action button icons.
  final bool showActionIcons;

  /// The content of the dialog.
  final Widget content;

  /// The error message to show.
  final String? error;

  /// The maximum width of the dialog.
  final double maxWidth;

  const DebtDialog({
    super.key,
    required this.title,
    this.action = 'Ok',
    this.onAction,
    this.showActionIcons = false,
    required this.content,
    this.error,
    this.maxWidth = 740,
  });

  Widget _buildTitle(BuildContext context) => Text(
        title,
        style: TextStyle(
          color: DebtColors.of(context).title,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _buildContent() => content;

  Widget _buildError(BuildContext context) => Text(
        error!,
        style: TextStyle(color: DebtColors.of(context).error),
      );

  Widget _buildOkButton(BuildContext context) => TextButton(
        style: TextButton.styleFrom(
          foregroundColor: DebtColors.of(context).accent,
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Ok'),
      );

  Widget _buildCancelButton(BuildContext context) => TextButton(
        style:
            TextButton.styleFrom(foregroundColor: DebtColors.of(context).title),
        onPressed: () => Navigator.of(context).pop(),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.close),
            SizedBox(width: 8),
            Text('Cancel'),
          ],
        ),
      );

  Widget _buildSaveButton() => TextButton(
        onPressed: onAction,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.check),
            const SizedBox(width: 8),
            Text(action),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTitle(context),
              const SizedBox(height: 24),
              _buildContent(),
              const SizedBox(height: 16),
              if (error != null) ...[
                _buildError(context),
                const SizedBox(height: 16),
              ],
              if (onAction == null)
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildOkButton(context),
                )
              else
                Row(
                  children: [
                    Expanded(child: _buildCancelButton(context)),
                    Expanded(child: _buildSaveButton()),
                  ],
                ),
            ],
          ),
        ),
      );
}
