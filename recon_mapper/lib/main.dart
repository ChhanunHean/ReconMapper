import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

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
      home: const PlaceholderHome(),
    );
  }
}

class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('ReconMapper — Dashboard coming soon')),
    );
  }
}
