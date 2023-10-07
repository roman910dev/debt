import 'package:debt/themes.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class DebtDialog extends StatefulWidget {
  final String title;
  final String action;
  final void Function()? onAction;
  final bool showActionIcons;
  final Widget content;

  const DebtDialog({
    super.key,
    required this.title,
    this.action = 'Ok',
    this.onAction,
    this.showActionIcons = false,
    required this.content,
  });

  @override
  createState() => DebtDialogState();
}

class DebtDialogState extends State<DebtDialog> {
  Widget _buildTitle() => Text(
        widget.title,
        style: TextStyle(
          color: DebtColors.of(context).title,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _buildContent() => widget.content;

  Widget _buildOkButton() => TextButton(
        style: TextButton.styleFrom(foregroundColor: DebtColors.of(context).accent),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Ok'),
      );

  Widget _buildCancelButton(BuildContext context) => TextButton(
        style: TextButton.styleFrom(foregroundColor: DebtColors.of(context).title),
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
        onPressed: widget.onAction,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.check),
            const SizedBox(width: 8),
            Text(widget.action),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 740),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTitle(),
              const SizedBox(height: 16),
              _buildContent(),
              const SizedBox(height: 16),
              if (widget.onAction == null)
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildOkButton(),
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
