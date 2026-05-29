import 'package:flutter/material.dart';
import '../models/printer.dart';

class ConnectionMethodSelector extends StatelessWidget {
  final ConnectionType? selected;
  final ValueChanged<ConnectionType> onSelected;

  const ConnectionMethodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ConnectionType.values.map((type) {
        final isSelected = selected == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onSelected(type),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xFF2A2A2A),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _iconFor(type),
                      color:
                          isSelected ? Colors.white : const Color(0xFF9E9E9E),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _labelFor(type),
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF9E9E9E),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconFor(ConnectionType type) {
    switch (type) {
      case ConnectionType.lan:
        return Icons.lan_outlined;
      case ConnectionType.usb:
        return Icons.usb;
      case ConnectionType.bluetooth:
        return Icons.bluetooth;
    }
  }

  String _labelFor(ConnectionType type) {
    switch (type) {
      case ConnectionType.lan:
        return 'LAN';
      case ConnectionType.usb:
        return 'USB';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
    }
  }
}
