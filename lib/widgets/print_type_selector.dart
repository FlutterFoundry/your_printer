import 'package:flutter/material.dart';
import '../providers/print_job_provider.dart';

class PrintTypeSelector extends StatelessWidget {
  final PrintType? selected;
  final ValueChanged<PrintType> onSelected;

  const PrintTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _TypeItem(PrintType.pdf, 'PDF', Icons.picture_as_pdf_outlined),
      _TypeItem(PrintType.plainText, 'Plain Text', Icons.text_fields),
      _TypeItem(PrintType.image, 'Image', Icons.image_outlined),
      _TypeItem(PrintType.webUrl, 'Web URL', Icons.language),
      _TypeItem(PrintType.screenshot, 'Screenshot', Icons.screenshot_outlined),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final isSelected = selected == item.type;
        return InkWell(
          onTap: () => onSelected(item.type),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TypeItem {
  final PrintType type;
  final String label;
  final IconData icon;

  const _TypeItem(this.type, this.label, this.icon);
}
