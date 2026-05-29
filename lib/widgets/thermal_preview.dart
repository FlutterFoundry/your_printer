import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../providers/print_job_provider.dart';

class ThermalPreview extends StatelessWidget {
  final PrintJobProvider job;

  const ThermalPreview({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final config = job.configuration;
    final paperWidth = config.paperSize.widthMm;

    return Center(
      child: Container(
        width: paperWidth * 1.6,
        constraints: const BoxConstraints(maxHeight: double.infinity),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _serratedEdge(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: _buildContent(context),
                ),
              ),
              _serratedEdge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serratedEdge() {
    return CustomPaint(
      size: const Size(double.infinity, 10),
      painter: _SerratedEdgePainter(),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (job.textContent != null) {
      return _buildTextPreview();
    }
    if (job.filePath != null) {
      return _buildImagePreview();
    }
    return const SizedBox.shrink();
  }

  Widget _buildTextPreview() {
    final config = job.configuration;
    final text = job.textContent!;
    final scale = config.scale;

    TextAlign textAlign;
    switch (config.textAlignment) {
      case TextAlignment.center:
        textAlign = TextAlign.center;
        break;
      case TextAlignment.right:
        textAlign = TextAlign.right;
        break;
      case TextAlignment.left:
        textAlign = TextAlign.left;
        break;
    }

    double fontSize = 13 * scale;
    if (config.textSize == TextSize.doubleHeight ||
        config.textSize == TextSize.doubleBoth) {
      fontSize *= 1.8;
    }

    final fontWeight = config.boldText ? FontWeight.w700 : FontWeight.w400;

    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: 'monospace',
          height: 1.3,
          letterSpacing: config.textSize == TextSize.doubleWidth ||
                  config.textSize == TextSize.doubleBoth
              ? 1.5
              : 0,
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final config = job.configuration;

    return FutureBuilder<ui.Image?>(
      future: _decodeImage(job.filePath!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Icon(Icons.broken_image, color: Colors.grey, size: 32);
        }
        final image = snapshot.data!;
        final scaledWidth =
            (config.paperSize.widthDots * config.scale).toDouble();
        final aspectRatio = image.height / image.width;
        final displayHeight = scaledWidth * aspectRatio;

        return RawImage(
          image: image,
          width: scaledWidth,
          height: displayHeight,
          fit: BoxFit.contain,
          color: Colors.white,
          colorBlendMode: BlendMode.dstIn,
        );
      },
    );
  }

  Future<ui.Image?> _decodeImage(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }
}

class _SerratedEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    final dotSpacing = 4.0;

    for (double x = 0; x < size.width; x += dotSpacing) {
      path.moveTo(x, 0);
      path.lineTo(x + 1, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
