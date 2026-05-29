import 'package:flutter/material.dart';
import '../models/printer.dart';

class PrinterFormDialog extends StatefulWidget {
  final Printer? printer;

  const PrinterFormDialog({super.key, this.printer});

  @override
  State<PrinterFormDialog> createState() => _PrinterFormDialogState();
}

class _PrinterFormDialogState extends State<PrinterFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late ConnectionType _connectionType;
  late final TextEditingController _ipController;
  late final TextEditingController _portController;
  late final TextEditingController _macController;
  late final TextEditingController _usbController;

  bool get _isEditing => widget.printer != null;

  @override
  void initState() {
    super.initState();
    final p = widget.printer;
    _nameController = TextEditingController(text: p?.name ?? '');
    _connectionType = p?.connectionType ?? ConnectionType.lan;
    _ipController = TextEditingController(text: p?.ipAddress ?? '');
    _portController = TextEditingController(text: p?.port?.toString() ?? '9100');
    _macController = TextEditingController(text: p?.macAddress ?? '');
    _usbController = TextEditingController(text: p?.usbIdentifier ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _macController.dispose();
    _usbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Printer' : 'Add Printer',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Printer Name',
                    hintText: 'e.g. Kitchen Receipt Printer',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ConnectionType>(
                  initialValue: _connectionType,
                  decoration: const InputDecoration(labelText: 'Connection Type'),
                  items: ConnectionType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t == ConnectionType.lan
                          ? 'LAN (Wi-Fi / Ethernet)'
                          : t == ConnectionType.usb
                              ? 'USB'
                              : 'Bluetooth'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _connectionType = v);
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (_connectionType == ConnectionType.lan) ...[
                  TextFormField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'IP Address',
                      hintText: '192.168.1.100',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'IP address is required for LAN'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      hintText: '9100',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                if (_connectionType == ConnectionType.usb)
                  TextFormField(
                    controller: _usbController,
                    decoration: const InputDecoration(
                      labelText: 'USB Identifier',
                      hintText: 'Device ID or serial',
                    ),
                  ),
                if (_connectionType == ConnectionType.bluetooth)
                  TextFormField(
                    controller: _macController,
                    decoration: const InputDecoration(
                      labelText: 'MAC Address / Device ID',
                      hintText: '00:11:22:33:44:55',
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(_isEditing ? 'Update' : 'Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final printer = Printer(
      id: widget.printer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      connectionType: _connectionType,
      ipAddress: _connectionType == ConnectionType.lan
          ? _ipController.text.trim()
          : null,
      port: _connectionType == ConnectionType.lan
          ? int.tryParse(_portController.text.trim()) ?? 9100
          : null,
      macAddress: _connectionType == ConnectionType.bluetooth
          ? _macController.text.trim()
          : null,
      usbIdentifier: _connectionType == ConnectionType.usb
          ? _usbController.text.trim()
          : null,
    );

    Navigator.of(context).pop(printer);
  }
}
