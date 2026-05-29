import 'package:flutter/material.dart';
import '../models/paper_size.dart';
import '../providers/print_job_provider.dart';
import '../theme/app_theme.dart';

class PrintConfigurationForm extends StatelessWidget {
  final PrintConfiguration configuration;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<int> onCopiesChanged;
  final ValueChanged<PaperSizeType> onPaperSizeChanged;
  final ValueChanged<int> onDensityChanged;
  final ValueChanged<bool> onCutPaperChanged;
  final ValueChanged<bool> onCashDrawerChanged;
  final ValueChanged<TextAlignment> onTextAlignmentChanged;
  final ValueChanged<TextSize> onTextSizeChanged;
  final ValueChanged<bool> onBoldTextChanged;
  final ValueChanged<int> onLineSpacingChanged;

  const PrintConfigurationForm({
    super.key,
    required this.configuration,
    required this.onScaleChanged,
    required this.onCopiesChanged,
    required this.onPaperSizeChanged,
    required this.onDensityChanged,
    required this.onCutPaperChanged,
    required this.onCashDrawerChanged,
    required this.onTextAlignmentChanged,
    required this.onTextSizeChanged,
    required this.onBoldTextChanged,
    required this.onLineSpacingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Paper Size'),
        const SizedBox(height: 8),
        _paperSizeSelector(context),
        const SizedBox(height: 20),
        _sectionLabel('Print Density'),
        const SizedBox(height: 8),
        _densitySlider(context),
        const SizedBox(height: 20),
        _sectionLabel('Size & Scaling'),
        const SizedBox(height: 8),
        _scaleSlider(context),
        const SizedBox(height: 20),
        _sectionLabel('Number of Copies'),
        const SizedBox(height: 8),
        _copiesStepper(context),
        const SizedBox(height: 20),
        _sectionLabel('Options'),
        const SizedBox(height: 8),
        _optionToggles(context),
        const SizedBox(height: 20),
        _sectionLabel('Text Formatting'),
        const SizedBox(height: 8),
        _textFormatting(context),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.muted,
      ),
    );
  }

  Widget _paperSizeSelector(BuildContext context) {
    return Row(
      children: PaperSizeType.values.map((size) {
        final isSelected = configuration.paperSize == size;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: size != PaperSizeType.values.last ? 8 : 0,
            ),
            child: InkWell(
              onTap: () => onPaperSizeChanged(size),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF9E9E9E),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      size.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF9E9E9E),
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

  Widget _densitySlider(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.texture, size: 18, color: Color(0xFF9E9E9E)),
        Expanded(
          child: Slider(
            value: configuration.printDensity.toDouble(),
            min: 1,
            max: 15,
            divisions: 14,
            activeColor: Theme.of(context).colorScheme.primary,
            label: '${configuration.printDensity}',
            onChanged: (v) => onDensityChanged(v.round()),
          ),
        ),
        const Icon(Icons.invert_colors, size: 18, color: Color(0xFF9E9E9E)),
      ],
    );
  }

  Widget _scaleSlider(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.zoom_out, size: 18, color: Color(0xFF9E9E9E)),
            Expanded(
              child: Slider(
                value: configuration.scale,
                min: 0.25,
                max: 2.0,
                divisions: 7,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: onScaleChanged,
              ),
            ),
            const Icon(Icons.zoom_in, size: 18, color: Color(0xFF9E9E9E)),
          ],
        ),
        Text(
          '${(configuration.scale * 100).round()}%',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _copiesStepper(BuildContext context) {
    return Row(
      children: [
        IconButton.outlined(
          onPressed: configuration.copies > 1
              ? () => onCopiesChanged(configuration.copies - 1)
              : null,
          icon: const Icon(Icons.remove),
        ),
        const SizedBox(width: 16),
        Text(
          '${configuration.copies}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 16),
        IconButton.outlined(
          onPressed: () => onCopiesChanged(configuration.copies + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _optionToggles(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto-cut paper'),
          subtitle: const Text('Cut after each print job',
              style: TextStyle(fontSize: 12)),
          value: configuration.cutPaper,
          activeTrackColor: Theme.of(context).colorScheme.primary,
          onChanged: onCutPaperChanged,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Open cash drawer'),
          subtitle: const Text('Pulse drawer after printing',
              style: TextStyle(fontSize: 12)),
          value: configuration.cashDrawer,
          activeTrackColor: Theme.of(context).colorScheme.primary,
          onChanged: onCashDrawerChanged,
        ),
      ],
    );
  }

  Widget _textFormatting(BuildContext context) {
    return Column(
      children: [
        Row(
          children: TextAlignment.values.map((align) {
            final isSelected = configuration.textAlignment == align;
            final label = align == TextAlignment.left
                ? 'Left'
                : align == TextAlignment.center
                    ? 'Center'
                    : 'Right';
            final icon = align == TextAlignment.left
                ? Icons.format_align_left
                : align == TextAlignment.center
                    ? Icons.format_align_center
                    : Icons.format_align_right;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: align != TextAlignment.values.last ? 8 : 0,
                ),
                child: InkWell(
                  onTap: () => onTextAlignmentChanged(align),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Icon(icon, size: 18,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF9E9E9E)),
                        const SizedBox(height: 2),
                        Text(label,
                            style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF9E9E9E))),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: TextSize.values.map((size) {
            final isSelected = configuration.textSize == size;
            final label = size == TextSize.normal
                ? '1x'
                : size == TextSize.doubleHeight
                    ? '2x H'
                    : size == TextSize.doubleWidth
                        ? '2x W'
                        : '2x Both';
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: size != TextSize.values.last ? 8 : 0,
                ),
                child: InkWell(
                  onTap: () => onTextSizeChanged(size),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(label,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF9E9E9E))),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilterChip(
                label: const Text('Bold'),
                selected: configuration.boldText,
                onSelected: onBoldTextChanged,
                selectedColor: Theme.of(context).colorScheme.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: configuration.boldText
                      ? Colors.white
                      : const Color(0xFF9E9E9E),
                  fontWeight: configuration.boldText
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Text('Spacing',
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                  Expanded(
                    child: Slider(
                      value: configuration.lineSpacing.toDouble(),
                      min: 10,
                      max: 60,
                      divisions: 10,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (v) => onLineSpacingChanged(v.round()),
                    ),
                  ),
                  Text('${configuration.lineSpacing}',
                      style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
