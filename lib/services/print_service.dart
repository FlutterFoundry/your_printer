import 'dart:io';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:image/image.dart' as img;
import '../models/paper_size.dart';
import '../providers/print_job_provider.dart';
import 'pdf_service.dart';

class PrintService {
  Future<List<int>> generatePrintData({
    required PrintType type,
    required PrintConfiguration config,
    String? imagePath,
    String? text,
    String? pdfPath,
  }) async {
    if (text != null) {
      return _repeat(await _generateText(text, config), config.copies);
    }
    if (pdfPath != null) {
      return _repeat(await _generatePdf(pdfPath, config), config.copies);
    }
    if (imagePath != null) {
      return _repeat(await _generateImage(imagePath, config), config.copies);
    }
    throw Exception('No content to print');
  }

  Future<List<int>> _generateText(String text, PrintConfiguration config) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(_paperSize(config.paperSize), profile);
    List<int> bytes = [];
    bytes += generator.reset();
    bytes += generator.setStyles(_buildPosStyles(config));
    bytes += generator.text(text);
    bytes += generator.feed(2);
    if (config.cashDrawer) bytes += generator.drawer();
    if (config.cutPaper) bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> _generateImage(
      String imagePath, PrintConfiguration config) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(_paperSize(config.paperSize), profile);
    List<int> bytes = [];
    bytes += generator.reset();
    final raster = await _imageToRaster(imagePath, config);
    bytes += generator.imageRaster(raster);
    bytes += generator.feed(2);
    if (config.cashDrawer) bytes += generator.drawer();
    if (config.cutPaper) bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> _generatePdf(
      String pdfPath, PrintConfiguration config) async {
    final pdfService = PdfService();
    final pageCount = await pdfService.getPageCount(pdfPath);
    final profile = await CapabilityProfile.load();
    final generator = Generator(_paperSize(config.paperSize), profile);
    List<int> bytes = [];
    bytes += generator.reset();

    for (int i = 1; i <= pageCount; i++) {
      final pagePath = await pdfService.renderPageToFile(pdfPath, i);
      if (pagePath == null) continue;
      final raster = await _imageToRaster(pagePath, config);
      bytes += generator.imageRaster(raster);
      if (i < pageCount) bytes += generator.feed(1);
    }

    bytes += generator.feed(2);
    if (config.cashDrawer) bytes += generator.drawer();
    if (config.cutPaper) bytes += generator.cut();
    return bytes;
  }

  Future<img.Image> _imageToRaster(
      String imagePath, PrintConfiguration config) async {
    final rawImage =
        img.decodeImage(await File(imagePath).readAsBytes());
    img.Image processed = rawImage!;

    if (config.cropArea != null) {
      processed = img.copyCrop(
        processed,
        config.cropArea!.left.round(),
        config.cropArea!.top.round(),
        config.cropArea!.width.round(),
        config.cropArea!.height.round(),
      );
    }

    if (config.scale != 1.0) {
      processed = img.copyResize(
        processed,
        width: (processed.width * config.scale).round(),
      );
    }

    img.Image resized =
        img.copyResize(processed, width: config.paperSize.widthDots);
    return img.grayscale(resized);
  }

  List<int> _repeat(List<int> commands, int copies) {
    List<int> result = [];
    for (int i = 0; i < copies; i++) {
      result.addAll(commands);
    }
    return result;
  }

  PaperSize _paperSize(PaperSizeType type) {
    switch (type) {
      case PaperSizeType.mm58:
        return PaperSize.mm58;
      case PaperSizeType.mm80:
        return PaperSize.mm80;
    }
  }

  PosStyles _buildPosStyles(PrintConfiguration config) {
    return PosStyles(
      bold: config.boldText,
      align: config.textAlignment == TextAlignment.left
          ? PosAlign.left
          : config.textAlignment == TextAlignment.center
              ? PosAlign.center
              : PosAlign.right,
      height: _posTextSizeHeight(config.textSize),
      width: _posTextSizeWidth(config.textSize),
    );
  }

  PosTextSize _posTextSizeHeight(TextSize size) {
    switch (size) {
      case TextSize.doubleHeight:
      case TextSize.doubleBoth:
        return PosTextSize.size2;
      default:
        return PosTextSize.size1;
    }
  }

  PosTextSize _posTextSizeWidth(TextSize size) {
    switch (size) {
      case TextSize.doubleWidth:
      case TextSize.doubleBoth:
        return PosTextSize.size2;
      default:
        return PosTextSize.size1;
    }
  }
}
