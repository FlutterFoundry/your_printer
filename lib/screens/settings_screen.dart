import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/printer.dart';
import '../providers/printer_provider.dart';
import '../widgets/printer_form_dialog.dart';
import '../widgets/printer_list_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Printers',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add_circle_outline),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<PrinterProvider>(
                builder: (context, provider, _) {
                  if (provider.printers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.print_outlined,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.15),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No printers added yet',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => _showAddDialog(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Printer'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: provider.printers.length,
                    itemBuilder: (context, index) {
                      final printer = provider.printers[index];
                      return PrinterListTile(
                        printer: printer,
                        onEdit: () => _showEditDialog(context, printer),
                        onDelete: () => _confirmDelete(context, printer),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<Printer>(
      context: context,
      builder: (_) => const PrinterFormDialog(),
    );
    if (result != null && context.mounted) {
      await context.read<PrinterProvider>().addPrinter(result);
    }
  }

  Future<void> _showEditDialog(BuildContext context, Printer printer) async {
    final result = await showDialog<Printer>(
      context: context,
      builder: (_) => PrinterFormDialog(printer: printer),
    );
    if (result != null && context.mounted) {
      await context.read<PrinterProvider>().updatePrinter(result);
    }
  }

  void _confirmDelete(BuildContext context, Printer printer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Printer'),
        content: Text('Remove "${printer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PrinterProvider>().deletePrinter(printer.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
