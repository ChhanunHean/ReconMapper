//----------------------------------------------------------------------------------
//             Small reusable loading indicator. Used on add_target_screen.dart
//        (while scanning) and target_detail_screen.dart (while loading export data).
//----------------------------------------------------------------------------------

import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  final String? message;

  const LoadingSpinner({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
    );
  }
}