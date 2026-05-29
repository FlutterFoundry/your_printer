import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdfx/pdfx.dart';

class PdfService {
  Future<String?> renderPageToFile(String pdfPath, int pageNum) async {
    try {
      final document = await PdfDocument.openFile(pdfPath);
      try {
        final page = await document.getPage(pageNum);
        final image = await page.render(
          width: page.width,
          height: page.height,
        );
        await page.close();

        final imageBytes = image?.bytes;
        if (imageBytes == null) return null;

        final dir = Directory.systemTemp;
        final outPath = '${dir.path}/pdf_preview_$pageNum.png';
        await File(outPath).writeAsBytes(imageBytes);
        return outPath;
      } finally {
        await document.close();
      }
    } catch (e) {
      debugPrint('PdfService render failed: $e');
      return null;
    }
  }

  Future<int> getPageCount(String pdfPath) async {
    final document = await PdfDocument.openFile(pdfPath);
    try {
      return document.pagesCount;
    } finally {
      await document.close();
    }
  }
}
