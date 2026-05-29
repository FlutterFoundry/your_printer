import 'package:hive_flutter/hive_flutter.dart';
import '../models/printer.dart';

class PrinterRepository {
  static const _boxName = 'printers';
  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PrinterAdapter());
    _box = await Hive.openBox(_boxName);
  }

  List<Printer> getAll() {
    return _box.values.cast<Printer>().toList();
  }

  Future<void> save(Printer printer) async {
    await _box.put(printer.id, printer);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<Printer> getByConnectionType(ConnectionType type) {
    return getAll().where((p) => p.connectionType == type).toList();
  }
}

class PrinterAdapter extends TypeAdapter<Printer> {
  @override
  final int typeId = 0;

  @override
  Printer read(BinaryReader reader) {
    final fields = reader.readMap().cast<int, dynamic>();
    return Printer(
      id: fields[0] as String,
      name: fields[1] as String,
      connectionType: ConnectionType.values[fields[2] as int],
      ipAddress: fields[3] as String?,
      port: fields[4] as int?,
      macAddress: fields[5] as String?,
      usbIdentifier: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Printer obj) {
    writer.writeMap({
      0: obj.id,
      1: obj.name,
      2: obj.connectionType.index,
      3: obj.ipAddress,
      4: obj.port,
      5: obj.macAddress,
      6: obj.usbIdentifier,
    });
  }
}
