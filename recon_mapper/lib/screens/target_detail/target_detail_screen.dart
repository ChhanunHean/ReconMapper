import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/api_service.dart';
import '../../models/scan_result.dart';
import '../../widgets/loading_spinner.dart';

class TargetDetailScreen extends StatefulWidget {
  final int targetId;

  const TargetDetailScreen({super.key, required this.targetId});

  @override
  State<TargetDetailScreen> createState() => _TargetDetailScreenState();
}

class _TargetDetailScreenState extends State<TargetDetailScreen> {
  final ApiService apiService = ApiService();

  ScanResult? result;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await apiService.exportTarget(widget.targetId);
      setState(() {
        result = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Couldn't load target details.";
      });
    }
  }
//----------------------------------------------------------------------------------------
//               Converts a 0-100 header score into a letter grade badge, similar
//               to how tools like securityheaders.com or SSL Labs present scores.
//-----------------------------------------------------------------------------------------
  String gradeLetter(int score) {
    if (score >= 90) return 'A';
    if (score >= 75) return 'B';
    if (score >= 60) return 'C';
    if (score >= 40) return 'D';
    return 'F';
  }

  Color gradeColor(int score) {
    if (score >= 75) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  Color riskColor(String level) {
    switch (level) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.amber;
      case 'High':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> exportReport() async {
    if (result == null) return;
    final r = result!;
//---------------------------------------------------------------------------------------
//            Rebuild the same JSON shape the backend's /export/{id} returns,
//            from the ScanResult we already have loaded - no extra API call needed.
//----------------------------------------------------------------------------------------
    final Map<String, dynamic> data = {
      "domain": r.domain,
      "ip": r.ip,
      "resolved": r.resolved,
      "ping_ms": r.pingMs,
      "alive": r.alive,
      "open_ports": r.openPorts,
      "ssl_valid": r.sslValid,
      "ssl_version": r.sslVersion,
      "ssl_days_left": r.sslDaysLeft,
      "ssl_issuer": r.sslIssuer,
      "header_score": r.headerScore,
      "headers_present": r.headersPresent,
      "headers_missing": r.headersMissing,
      "risk_score": r.riskScore,
      "risk_level": r.riskLevel,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    await Share.share(
      jsonString,
      subject: 'ReconMapper scan report - ${r.domain}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(result?.domain ?? 'Target Detail'),
      ),
      body: isLoading
          ? const LoadingSpinner(message: 'Loading target details...')
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : _buildDetail(),
    );
  }

  Widget _buildDetail() {
    final r = result!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.black,
                child: Text(
                  r.domain.isNotEmpty ? r.domain[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.domain,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Last scanned just now',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _detailRow('IP', r.ip ?? '-'),
          _detailRow(
            'STATUS',
            r.alive ? 'Alive' : 'Unreachable',
            valueColor: r.alive ? Colors.green : Colors.red,
          ),
          _detailRow('PING', r.pingMs != null ? '${r.pingMs!.round()}ms' : '-'),
          _detailRow('LOCATION', '-'), 
          _detailRow(
            'OPEN PORTS',
            r.openPorts.isEmpty ? 'None found' : r.openPorts.join(', '),
          ),
          _detailRow('SERVER VERSION', '-'), 

          const SizedBox(height: 12),
          const Text(
            'SECURITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          _detailRowWidget(
            'HEADER SCORE',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${r.headerScore}/100'),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: gradeColor(r.headerScore),
                  child: Text(
                    gradeLetter(r.headerScore),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          _detailRow(
            'SSL / TLS',
            r.sslValid
                ? '${r.sslVersion ?? "Valid"} - ${r.sslDaysLeft ?? "?"}d left'
                : 'Invalid / Not present',
            valueColor: r.sslValid ? Colors.green : Colors.red,
          ),
          _detailRow('WAF', '-'), 
          _detailRow('TECH STACK', '-'), 

          const SizedBox(height: 12),
          _detailRowWidget(
            'RISK LEVEL',
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: riskColor(r.riskLevel).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${r.riskScore} - ${r.riskLevel}',
                style: TextStyle(
                  color: riskColor(r.riskLevel),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (r.headersMissing.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Missing security headers',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: r.headersMissing
                  .map((h) => Chip(label: Text(h, style: const TextStyle(fontSize: 12))))
                  .toList(),
            ),
          ],

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: exportReport,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Export', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return _detailRowWidget(
      label,
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ),
    );
  }

  Widget _detailRowWidget(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          valueWidget,
        ],
      ),
    );
  }
}