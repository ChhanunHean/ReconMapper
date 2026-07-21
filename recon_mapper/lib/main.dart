import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(const ReconMapperApp());
}

class ReconMapperApp extends StatelessWidget {
  const ReconMapperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReconMapper',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
