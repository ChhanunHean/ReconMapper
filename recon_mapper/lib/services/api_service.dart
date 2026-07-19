// services/api_service.dart
//
// All HTTP calls to the FastAPI backend live here.
// Nothing else in the app should call http directly - screens call
// these functions instead.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/target.dart';
import '../models/scan_result.dart';

class ApiService {
  // iOS Simulator / Mac testing: 127.0.0.1 works fine.
  // Android emulator: use 10.0.2.2 instead.
  // Real phone on same Wi-Fi: use your computer's local IP, e.g. 192.168.1.42
  static const String baseUrl = "http://10.0.2.2:8000";

  // GET /targets -> list for the dashboard
  Future<List<Target>> getTargets() async {
    final response = await http.get(Uri.parse("$baseUrl/targets"));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<Target> targets = [];
      for (var item in jsonList) {
        targets.add(Target.fromJson(item));
      }
      return targets;
    } else {
      throw Exception("Failed to load targets (status ${response.statusCode})");
    }
  }

  // POST /scan -> runs a new scan on a domain, returns full result
  Future<ScanResult> scanTarget(String domain) async {
    final response = await http.post(
      Uri.parse("$baseUrl/scan"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"domain": domain}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return ScanResult.fromJson(json);
    } else {
      throw Exception("Scan failed (status ${response.statusCode})");
    }
  }

  // GET /export/{id} -> full saved scan JSON for a target
  Future<ScanResult> exportTarget(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/export/$id"));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return ScanResult.fromJson(json);
    } else {
      throw Exception("Export failed (status ${response.statusCode})");
    }
  }
}