import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/target.dart';

void main() {
  // TEMPORARY TEST — remove this block once confirmed working
  final testJson = {
    "id": 1,
    "domain": "google.com",
    "ip": "142.250.185.46",
    "ping_ms": 42.8,
    "risk_score": 76,
    "risk_level": "Medium",
    "last_scanned": "2026-07-17T17:33:04.199059"
  };

  final target = Target.fromJson(testJson);

  print("id: ${target.id}");
  print("domain: ${target.domain}");
  print("ip: ${target.ip}");
  print("ping: ${target.ping}");
  print("riskScore: ${target.riskScore}");
  print("riskLevel: ${target.riskLevel}");
  print("lastScanned: ${target.lastScanned}");
  // END TEMPORARY TEST

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