import 'package:debt/config.dart';
import 'package:debt/themes.dart';
import 'package:debt/widgets/debt_edit_dialog.dart';
import 'package:debt/widgets/selection_controller.dart';
import 'package:flutter/material.dart';

class _CalculatorToggle extends StatefulWidget {
  final BoolController controller;
  const _CalculatorToggle(this.controller);

  @override
  State<_CalculatorToggle> createState() => __CalculatorToggleState();
}

class __CalculatorToggleState extends State<_CalculatorToggle> {
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => setState(() => widget.controller.toggle()),
        hoverColor: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : null,
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
                onChanged: (val) => setState(() => widget.controller.value = val),
              ),
            ],
          ),
        ),
      );
}

class CalculatorDialog extends StatelessWidget {
  CalculatorDialog({super.key});

  final BoolController _controller = BoolController(DebtSettings.calculatorEnabled);

  Widget _buildInfo() => Text(
        'If calculator input is disabled, a numerical keyboard will show when filling in money fields.\n'
        '\n'
        'If it is enabled, a full keyboard will be shown so you can enter expressions like +, -, * and /.\n'
        '\n'
        'e.g. "11.34/5" will be saved as "2.27".',
        textAlign: DebtData.iOSWeb ? TextAlign.left : TextAlign.start,
      );

  @override
  Widget build(BuildContext context) => DebtDialog(
        title: 'Calculator input',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfo(),
            const SizedBox(height: 24),
            _CalculatorToggle(_controller),
          ],
        ),
        action: 'Save',
        onAction: () async {
          final bool changed = DebtSettings.calculatorEnabled != _controller.value;
          if (changed) DebtSettings.calculatorEnabled = _controller.value;
          Navigator.of(context).pop(changed);
        },
      );
}
