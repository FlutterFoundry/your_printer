enum PaperSizeType {
  mm58('58mm', 58, 372),
  mm80('80mm', 80, 558);

  const PaperSizeType(this.label, this.widthMm, this.widthDots);
  final String label;
  final int widthMm;
  final int widthDots;
}
