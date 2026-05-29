import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/print_job_provider.dart';
import '../widgets/print_configuration_form.dart';
import '../widgets/thermal_preview.dart';
import '../widgets/image_crop_overlay.dart';

class PrintConfigurationScreen extends StatefulWidget {
  const PrintConfigurationScreen({super.key});

  @override
  State<PrintConfigurationScreen> createState() =>
      _PrintConfigurationScreenState();
}

class _PrintConfigurationScreenState extends State<PrintConfigurationScreen> {
  double _sheetRatio = 0.55;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<PrintJobProvider>().goBack();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Consumer<PrintJobProvider>(
          builder: (context, job, _) {
            return Stack(
              children: [
                Positioned.fill(
                  child: _buildPreview(context, job),
                ),
                NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    setState(() => _sheetRatio = notification.extent);
                    return false;
                  },
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.55,
                    minChildSize: 0.12,
                    maxChildSize: 0.85,
                    snap: true,
                    snapSizes: const [0.12, 0.55, 0.85],
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          children: [
                            _dragHandle(),
                            if (_sheetRatio > 0.14) ...[
                              if (job.filePath != null &&
                                  (job.type == PrintType.image ||
                                      job.type == PrintType.screenshot ||
                                      job.type == PrintType.pdf)) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 20),
                                  child: _cropButton(context, job),
                                ),
                                const SizedBox(height: 8),
                              ],
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: PrintConfigurationForm(
                                  configuration: job.configuration,
                                  onScaleChanged: (v) => job.setScale(v),
                                  onCopiesChanged: (v) => job.setCopies(v),
                                  onPaperSizeChanged: (v) =>
                                      job.setPaperSize(v),
                                  onDensityChanged: (v) =>
                                      job.setPrintDensity(v),
                                  onCutPaperChanged: (v) =>
                                      job.setCutPaper(v),
                                  onCashDrawerChanged: (v) =>
                                      job.setCashDrawer(v),
                                  onTextAlignmentChanged: (v) =>
                                      job.setTextAlignment(v),
                                  onTextSizeChanged: (v) =>
                                      job.setTextSize(v),
                                  onBoldTextChanged: (v) =>
                                      job.setBoldText(v),
                                  onLineSpacingChanged: (v) =>
                                      job.setLineSpacing(v),
                                ),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    job.goToConnect();
                                    Navigator.pushNamed(context, '/connect');
                                  },
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Choose Connection'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _dragHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF9E9E9E).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _cropButton(BuildContext context, PrintJobProvider job) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _openCropScreen(context, job),
        icon: const Icon(Icons.crop, size: 18),
        label: Text(job.configuration.cropArea != null
            ? 'Crop area set (tap to change)'
            : 'Crop Image'),
      ),
    );
  }

  Future<void> _openCropScreen(
      BuildContext context, PrintJobProvider job) async {
    final cropNotifier = ValueNotifier<Rect?>(job.configuration.cropArea);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CropScreen(
          imagePath: job.filePath!,
          initialCrop: job.configuration.cropArea,
          cropNotifier: cropNotifier,
        ),
      ),
    );

    job.setCropArea(cropNotifier.value);
    cropNotifier.dispose();
  }

  Widget _buildPreview(BuildContext context, PrintJobProvider job) {
    if (job.filePath == null && job.textContent == null) {
      return Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.15),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ThermalPreview(job: job),
    );
  }
}

class _CropScreen extends StatefulWidget {
  final String imagePath;
  final Rect? initialCrop;
  final ValueNotifier<Rect?> cropNotifier;

  const _CropScreen({
    required this.imagePath,
    required this.initialCrop,
    required this.cropNotifier,
  });

  @override
  State<_CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<_CropScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        actions: [
          TextButton(
            onPressed: () {
              widget.cropNotifier.value = null;
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ImageCropOverlay(
            imagePath: widget.imagePath,
            initialCrop: widget.initialCrop,
            onCropChanged: (rect) {
              widget.cropNotifier.value = rect;
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply Crop'),
          ),
        ),
      ),
    );
  }
}
