import 'package:debt/config.dart';
import 'package:debt/themes.dart';
import 'package:debt/modals/debt_dialog.dart';
import 'package:debt/tools.dart';
import 'package:flutter/material.dart';

/// The switch used in [CalculatorInputSettingsDialog].
class _CalculatorSwitch extends StatefulWidget {
  final BoolController controller;
  const _CalculatorSwitch(this.controller);

  @override
  State<_CalculatorSwitch> createState() => _CalculatorSwitchState();
}

class _CalculatorSwitchState extends State<_CalculatorSwitch> {
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => setState(() => widget.controller.toggle()),
        hoverColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.transparent
            : null,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            color: DebtColors.of(context).background,
          ),
          padding: const EdgeInsets.only(left: 24, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Calculator input'),
              const SizedBox(width: 8),
              Switch(
                value: widget.controller.value,
                activeColor: Theme.of(context).colorScheme.secondary,
                onChanged: (val) =>
                    setState(() => widget.controller.value = val),
              ),
            ],
          ),
        ),
      );
}

/// A dialog that allows the user to change the calculator input setting.
class CalculatorInputSettingsDialog extends StatelessWidget {
  CalculatorInputSettingsDialog({super.key});

  final BoolController _controller =
      BoolController(DebtSettings.calculatorInput);

  Widget _buildInfo() => Text(
        'If calculator input is disabled, a numerical keyboard will show when filling in money fields.\n'
        '\n'
        'If it is enabled, a full keyboard will be shown so you can enter expressions like +, -, * and /.\n'
        '\n'
        'e.g. "11.34/5" will be saved as "2.27".',
        textAlign: DebtEnv.iOSWeb ? TextAlign.left : TextAlign.start,
      );

  @override
  Widget build(BuildContext context) => DebtDialog(
        maxWidth: 480,
        title: 'Calculator input',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfo(),
            const SizedBox(height: 24),
            _CalculatorSwitch(_controller),
          ],
        ),
        action: 'Save',
        onAction: () async {
          final bool changed =
              DebtSettings.calculatorInput != _controller.value;
          if (changed) DebtSettings.calculatorInput = _controller.value;
          Navigator.of(context).pop(changed);
        },
      );
}
