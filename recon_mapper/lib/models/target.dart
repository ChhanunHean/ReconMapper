//-------------------------------------------------------------------------------------
//                      Represents a recon target with scan results
//-------------------------------------------------------------------------------------
class Target {
  final int? id;
  final String domain;
  final String? ip;
  final double? ping;
  final int? riskScore;
  final String? riskLevel;
  final String? lastScanned; // this use for date last scaned(Ex.2026-07-17T10:33:04.19)

  Target({
    this.id,
    required this.domain,
    this.ip,
    this.ping,
    this.riskScore,
    this.riskLevel,
    this.lastScanned,
  });
  //----------------------------------------------------------
  // Converts raw JSON from the backend into a Target object.
  //----------------------------------------------------------
  factory Target.fromJson(Map<String, dynamic> json) {
    return Target(
      id: json["id"], 
      domain: json["domain"],
      ip: json["ip"],
      ping: json["ping"],
      riskScore: json["riskScore"],
      riskLevel: json["riskLevel"],
      lastScanned: json["lastScanned"]
    );
  }
}
