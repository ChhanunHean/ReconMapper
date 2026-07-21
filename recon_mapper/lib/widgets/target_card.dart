//-------------------------------------------------------------------------------------
// A single row/card in the dashboard target list.
// Tapping it navigates to TargetDetailScreen.
//-------------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import '../models/target.dart';
import '../screens/target_detail/target_detail_screen.dart';
import 'risk_badge.dart';

class TargetCard extends StatelessWidget {
  final Target target;

  const TargetCard({super.key, required this.target});

  // Trim the ISO date string to just "YYYY-MM-DD" for display
  String _formatDate(String? raw) {
    if (raw == null) return 'Never';
    return raw.length >= 10 ? raw.substring(0, 10) : raw;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Only navigate if we actually have an ID saved in the backend
          if (target.id == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TargetDetailScreen(targetId: target.id!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              //-----------------------------------
              // Avatar: first letter of domain
              //-----------------------------------
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primaryRed.withValues(alpha: 0.12),
                child: Text(
                  target.domain.isNotEmpty
                      ? target.domain[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppTheme.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              //-----------------------------------
              // Domain + IP + last scanned
              //-----------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      target.domain,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      target.ip ?? 'IP unknown',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last scanned: ${_formatDate(target.lastScanned)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              //-----------------------------------
              // Risk badge + chevron
              //-----------------------------------
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RiskBadge(level: target.riskLevel),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pull the color constant from theme without importing the whole file redundantly
class AppTheme {
  static const Color primaryRed = Color(0xFFE74C3C);
}
