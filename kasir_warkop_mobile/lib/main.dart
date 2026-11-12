import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/shell/pos_shell_screen.dart';
import 'providers/pos_provider.dart';
import 'providers/product_provider.dart';
import 'providers/report_provider.dart';

void main() {
  runApp(const KasirWarkopApp());
}

/// Root widget aplikasi POS Warkop Sukses.
class KasirWarkopApp extends StatelessWidget {
  const KasirWarkopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => PosProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        title: 'Kasir Warkop Sukses',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const PosShellScreen(),
      ),
    );
  }
}
