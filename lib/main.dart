import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'repositories/printer_repository.dart';
import 'providers/printer_provider.dart';
import 'providers/print_job_provider.dart';
import 'screens/home_screen.dart';
import 'screens/print_configuration_screen.dart';
import 'screens/connection_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final printerRepository = PrinterRepository();
  await printerRepository.init();

  final printerProvider = PrinterProvider(printerRepository);
  await printerProvider.loadPrinters();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: printerProvider),
        ChangeNotifierProvider(create: (_) => PrintJobProvider()),
      ],
      child: const YourPrinterApp(),
    ),
  );
}

class YourPrinterApp extends StatelessWidget {
  const YourPrinterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Printer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/configure': (_) => const PrintConfigurationScreen(),
        '/connect': (_) => const ConnectionScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
