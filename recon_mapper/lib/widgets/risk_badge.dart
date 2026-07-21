//-------------------------------------------------------------------------------------
// Colored pill badge showing risk level.
// Used by TargetCard on the dashboard.
// Colors match the riskColor() logic already in target_detail_screen.dart
//-------------------------------------------------------------------------------------
import 'package:flutter/material.dart';

class RiskBadge extends StatelessWidget {
  final String? level; // "Low" | "Medium" | "High" | "Critical" | null

  const RiskBadge({super.key, required this.level});

  Color _bgColor() {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor().withValues(alpha: 0.15),
        border: Border.all(color: _bgColor(), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level ?? 'Unknown',
        style: TextStyle(
          color: _bgColor(),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
