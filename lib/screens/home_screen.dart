import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/print_job_provider.dart';
import '../services/pdf_service.dart';
import '../widgets/print_type_selector.dart';
import '../widgets/thermal_preview.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Printer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<PrintJobProvider>(
                builder: (context, job, _) {
                  return _buildPreview(context, job);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Print Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                  Consumer<PrintJobProvider>(
                    builder: (context, job, _) {
                      return PrintTypeSelector(
                        selected: job.type,
                        onSelected: (type) {
                          job.selectType(type);
                          if (type == PrintType.plainText) {
                            _showTextInputDialog(context, job);
                          } else if (type == PrintType.image ||
                              type == PrintType.pdf) {
                            _pickFile(context, job, type);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<PrintJobProvider>(
                    builder: (context, job, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: job.type != null &&
                                  (job.filePath != null ||
                                      job.textContent != null)
                              ? () => Navigator.pushNamed(context, '/configure')
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Continue'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, PrintJobProvider job) {
    if (job.type == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.print_outlined,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.15),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a print type below to begin',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      );
    }

    if (job.filePath != null || job.textContent != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ThermalPreview(job: job),
      );
    }

    return Center(
      child: Text(
        'Select a file to preview',
        style: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.3),
        ),
      ),
    );
  }

  void _showTextInputDialog(BuildContext context, PrintJobProvider job) {
    final controller = TextEditingController(text: job.textContent);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Text'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Type or paste your text here...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              job.setTextContent(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Set Text'),
          ),
        ],
      ),
    );
  }

  void _pickFile(
      BuildContext context, PrintJobProvider job, PrintType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: type == PrintType.pdf ? FileType.custom : FileType.image,
      allowedExtensions: type == PrintType.pdf ? ['pdf'] : null,
    );
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;

    if (type == PrintType.pdf) {
      if (!context.mounted) return;
      _showLoading(context);
      try {
        final pdfService = PdfService();
        final imagePath = await pdfService.renderPageToFile(path, 1);
        if (!context.mounted) return;
        Navigator.pop(context);
        if (imagePath != null) {
          job.setOriginalPath(path);
          job.setFile(imagePath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to render PDF preview. '
                  'The file can still be printed.'),
            ),
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PDF: $e')),
        );
      }
    } else {
      job.setOriginalPath(null);
      job.setFile(path);
    }
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading PDF...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
