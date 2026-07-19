// models/scan_result.dart
//
// Represents the FULL scan output from the backend - returned by
// POST /scan and GET /export/{id}. This is different from Target
// (in target.dart), which only holds the summary fields used by
// the dashboard list (GET /targets).
//
// Kept in its own file (rather than added to target.dart) since
// target.dart belongs to Member A - this avoids both of us editing
// the same file and creating merge conflicts.

class ScanResult {
  final String domain;
  final String? ip;
  final bool resolved;
  final double? pingMs;
  final bool alive;
  final List<int> openPorts;
  final bool sslValid;
  final String? sslVersion;
  final int? sslDaysLeft;
  final String? sslIssuer;
  final int headerScore;
  final List<String> headersPresent;
  final List<String> headersMissing;
  final int riskScore;
  final String riskLevel;

  ScanResult({
    required this.domain,
    this.ip,
    required this.resolved,
    this.pingMs,
    required this.alive,
    required this.openPorts,
    required this.sslValid,
    this.sslVersion,
    this.sslDaysLeft,
    this.sslIssuer,
    required this.headerScore,
    required this.headersPresent,
    required this.headersMissing,
    required this.riskScore,
    required this.riskLevel,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    List<int> ports = [];
    if (json['open_ports'] != null) {
      for (var p in json['open_ports']) {
        ports.add(p as int);
      }
    }

    List<String> present = [];
    if (json['headers_present'] != null) {
      for (var h in json['headers_present']) {
        present.add(h as String);
      }
    }

    List<String> missing = [];
    if (json['headers_missing'] != null) {
      for (var h in json['headers_missing']) {
        missing.add(h as String);
      }
    }

    return ScanResult(
      domain: json['domain'],
      ip: json['ip'],
      resolved: json['resolved'],
      pingMs: json['ping_ms'] == null ? null : (json['ping_ms'] as num).toDouble(),
      alive: json['alive'],
      openPorts: ports,
      sslValid: json['ssl_valid'],
      sslVersion: json['ssl_version'],
      sslDaysLeft: json['ssl_days_left'],
      sslIssuer: json['ssl_issuer'],
      headerScore: json['header_score'],
      headersPresent: present,
      headersMissing: missing,
      riskScore: json['risk_score'],
      riskLevel: json['risk_level'],
    );
  }
}