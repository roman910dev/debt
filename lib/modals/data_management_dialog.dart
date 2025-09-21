import 'dart:convert';

import 'package:debt/config.dart';
import 'package:debt/modals/debt_dialog.dart';
import 'package:debt/scripts/classes.dart';
import 'package:debt/themes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';

/// An option for the data management dialog.
class _DataManagementOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(BuildContext context) onAction;

  const _DataManagementOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onAction,
  });
}

/// A dialog that provides options to export and import debt data.
class DataManagementDialog extends StatelessWidget {
  const DataManagementDialog({super.key});

  Future<void> _exportData(BuildContext context) async {
    try {
      final csvContent = people.people.toCsv();

      final file = XFile.fromData(
        utf8.encode(csvContent),
        mimeType: 'text/csv',
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [file],
          text: 'Debt Tracker Export',
          subject: 'Debt Tracker Data Export',
          fileNameOverrides: ['debt_export.csv'],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export: $e'),
          backgroundColor: DebtColors.of(context).error,
        ),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final csvContent = utf8.decode(file.bytes!);
      final importedPeople = people.people.fromCsv(csvContent);
      final entries = importedPeople.expand((p) => p.entries).toList();

      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => DebtDialog(
          title: 'Import Data',
          content: Text(
            'Found ${entries.length} entries from ${importedPeople.length} people to import.\n\n'
            'This will add the imported entries to your existing data.\n\n'
            'Do you want to continue?',
          ),
          action: 'Import',
          onAction: () => Navigator.of(context).pop(true),
        ),
      );
      if (confirmed != true) return;

      people.addAll(entries);

      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully imported ${entries.length} entries'),
          backgroundColor: DebtColors.of(context).accent,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import data'),
          backgroundColor: DebtColors.of(context).error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      _DataManagementOption(
        icon: Symbols.file_save,
        title: 'Export',
        subtitle: 'Export your data to a file that you can share or backup.',
        onAction: _exportData,
      ),
      _DataManagementOption(
        icon: Symbols.upload_file,
        title: 'Import',
        subtitle: 'Import data from a previously exported file. '
            'Imported data will be added to your existing data.',
        onAction: _importData,
      ),
    ];

    return DebtDialog(
      title: 'Manage Data',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: options
            .map(
              (o) => ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                leading: Icon(o.icon),
                title: Text(o.title),
                subtitle: Text(o.subtitle),
                onTap: () => o.onAction(context),
              ),
            )
            .toList(),
      ),
      defaultAction: 'Cancel',
    );
  }
}
