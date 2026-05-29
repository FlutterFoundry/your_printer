import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/paper_size.dart';

enum TextAlignment { left, center, right }

enum TextSize { normal, doubleHeight, doubleWidth, doubleBoth }

enum PrintType { pdf, plainText, image, webUrl, screenshot }

enum PrintJobStep { selectType, configure, connect, print }

class PrintConfiguration {
  double scale;
  int copies;
  Rect? cropArea;
  PaperSizeType paperSize;
  int printDensity;
  bool cutPaper;
  bool cashDrawer;
  TextAlignment textAlignment;
  TextSize textSize;
  bool boldText;
  int lineSpacing;

  PrintConfiguration({
    this.scale = 1.0,
    this.copies = 1,
    this.cropArea,
    this.paperSize = PaperSizeType.mm80,
    this.printDensity = 7,
    this.cutPaper = true,
    this.cashDrawer = false,
    this.textAlignment = TextAlignment.left,
    this.textSize = TextSize.normal,
    this.boldText = false,
    this.lineSpacing = 30,
  });
}

class PrintJobProvider extends ChangeNotifier {
  PrintType? _type;
  String? _filePath;
  String? _originalPath;
  String? _textContent;
  final PrintConfiguration configuration = PrintConfiguration();
  PrintJobStep _step = PrintJobStep.selectType;

  PrintType? get type => _type;
  String? get filePath => _filePath;
  String? get originalPath => _originalPath;
  String? get textContent => _textContent;
  PrintJobStep get step => _step;

  void selectType(PrintType type) {
    _type = type;
    _step = PrintJobStep.configure;
    notifyListeners();
  }

  void setFile(String path) {
    _filePath = path;
    notifyListeners();
  }

  void setOriginalPath(String? path) {
    _originalPath = path;
  }

  void setTextContent(String text) {
    _textContent = text;
    notifyListeners();
  }

  void setScale(double scale) {
    configuration.scale = scale;
    notifyListeners();
  }

  void setCopies(int copies) {
    configuration.copies = copies;
    notifyListeners();
  }

  void setPaperSize(PaperSizeType size) {
    configuration.paperSize = size;
    notifyListeners();
  }

  void setPrintDensity(int density) {
    configuration.printDensity = density;
    notifyListeners();
  }

  void setCutPaper(bool cut) {
    configuration.cutPaper = cut;
    notifyListeners();
  }

  void setCashDrawer(bool open) {
    configuration.cashDrawer = open;
    notifyListeners();
  }

  void setTextAlignment(TextAlignment alignment) {
    configuration.textAlignment = alignment;
    notifyListeners();
  }

  void setTextSize(TextSize size) {
    configuration.textSize = size;
    notifyListeners();
  }

  void setBoldText(bool bold) {
    configuration.boldText = bold;
    notifyListeners();
  }

  void setLineSpacing(int spacing) {
    configuration.lineSpacing = spacing;
    notifyListeners();
  }

  void setCropArea(Rect? rect) {
    configuration.cropArea = rect;
    notifyListeners();
  }

  void goToConnect() {
    _step = PrintJobStep.connect;
    notifyListeners();
  }

  void goToPrint() {
    _step = PrintJobStep.print;
    notifyListeners();
  }

  void goBack() {
    switch (_step) {
      case PrintJobStep.configure:
        _step = PrintJobStep.selectType;
        break;
      case PrintJobStep.connect:
        _step = PrintJobStep.configure;
        break;
      case PrintJobStep.print:
        _step = PrintJobStep.connect;
        break;
      case PrintJobStep.selectType:
        break;
    }
    notifyListeners();
  }

  void reset() {
    _type = null;
    _filePath = null;
    _textContent = null;
    _step = PrintJobStep.selectType;
    notifyListeners();
  }
}
