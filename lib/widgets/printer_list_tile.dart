import 'package:flutter/material.dart';
import '../models/printer.dart';

class PrinterListTile extends StatelessWidget {
  final Printer printer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PrinterListTile({
    super.key,
    required this.printer,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          _connectionIcon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          printer.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          _subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }

  IconData get _connectionIcon {
    switch (printer.connectionType) {
      case ConnectionType.lan:
        return Icons.lan_outlined;
      case ConnectionType.usb:
        return Icons.usb;
      case ConnectionType.bluetooth:
        return Icons.bluetooth;
    }
  }

  String get _subtitle {
    final type = printer.connectionLabel;
    final detail = printer.ipAddress ??
        printer.macAddress ??
        printer.usbIdentifier ??
        '';
    return '$type${detail.isNotEmpty ? ' - $detail' : ''}';
  }
}
