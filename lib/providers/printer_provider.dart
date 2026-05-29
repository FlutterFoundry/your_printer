import 'package:flutter/foundation.dart';
import '../models/printer.dart';
import '../repositories/printer_repository.dart';

class PrinterProvider extends ChangeNotifier {
  final PrinterRepository _repository;
  List<Printer> _printers = [];

  PrinterProvider(this._repository);

  List<Printer> get printers => List.unmodifiable(_printers);

  List<Printer> printersForType(ConnectionType type) =>
      _printers.where((p) => p.connectionType == type).toList();

  Future<void> loadPrinters() async {
    _printers = _repository.getAll();
    notifyListeners();
  }

  Future<void> addPrinter(Printer printer) async {
    await _repository.save(printer);
    _printers = _repository.getAll();
    notifyListeners();
  }

  Future<void> updatePrinter(Printer printer) async {
    await _repository.save(printer);
    _printers = _repository.getAll();
    notifyListeners();
  }

  Future<void> deletePrinter(String id) async {
    await _repository.delete(id);
    _printers = _repository.getAll();
    notifyListeners();
  }
}
