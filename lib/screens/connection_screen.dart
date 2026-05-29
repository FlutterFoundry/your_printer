import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/printer.dart';
import '../providers/printer_provider.dart';
import '../providers/print_job_provider.dart';
import '../services/print_service.dart';
import '../services/connection_service.dart';
import '../widgets/connection_method_selector.dart';
import '../widgets/printer_list_tile.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  ConnectionType? _selectedConnection;
  final ConnectionService _connectionService = ConnectionService();
  final PrintService _printService = PrintService();
  bool _isPrinting = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect & Print'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<PrintJobProvider>().goBack();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Connection Method',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ConnectionMethodSelector(
                selected: _selectedConnection,
                onSelected: (type) {
                  setState(() => _selectedConnection = type);
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Saved Printers',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _discover(context),
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Discover'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<PrinterProvider>(
                builder: (context, printerProvider, _) {
                  final printers = _selectedConnection == null
                      ? printerProvider.printers
                      : printerProvider.printersForType(_selectedConnection!);

                  if (printers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.print_outlined,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.15),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedConnection == null
                                ? 'Select a connection method'
                                : 'No saved printers for this connection.\nAdd one in Settings.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
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

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: printers.length,
                    itemBuilder: (context, index) {
                      return PrinterListTile(
                        printer: printers[index],
                        onTap: () => _print(context, printers[index]),
                      );
                    },
                  );
                },
              ),
            ),
            if (_statusMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: _isPrinting
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                    : const Color(0xFF2A2A2A),
                child: Row(
                  children: [
                    if (_isPrinting)
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFE7114),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _print(BuildContext context, Printer printer) async {
    setState(() {
      _isPrinting = true;
      _statusMessage = 'Preparing print job...';
    });

    try {
      final job = context.read<PrintJobProvider>();
      final commands = await _printService.generatePrintData(
        type: job.type!,
        config: job.configuration,
        text: job.textContent,
        imagePath: job.filePath,
        pdfPath: job.originalPath,
      );

      setState(() => _statusMessage = 'Sending to ${printer.name}...');

      await _connectionService.send(printer, commands);

      setState(() {
        _isPrinting = false;
        _statusMessage = 'Sent to ${printer.name}';
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _statusMessage = null);
      }
    } catch (e) {
      setState(() {
        _isPrinting = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  void _discover(BuildContext context) {
    if (_selectedConnection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a connection method first')),
      );
      return;
    }
    setState(() {
      _statusMessage = 'Discovery not available in simulator';
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _statusMessage = null);
      }
    });
  }
}
