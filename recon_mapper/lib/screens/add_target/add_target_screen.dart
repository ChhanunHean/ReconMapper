// screens/add_target/add_target_screen.dart
//
// Form screen: user types a domain/IP, taps "Scan", we call the backend
// via ApiService().scanTarget(), then pop back to the dashboard so it
// can refresh its list and show the new/updated target.

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_spinner.dart';

class AddTargetScreen extends StatefulWidget {
  const AddTargetScreen({super.key});

  @override
  State<AddTargetScreen> createState() => _AddTargetScreenState();
}

class _AddTargetScreenState extends State<AddTargetScreen> {
  final TextEditingController domainController = TextEditingController();
  final ApiService apiService = ApiService();

  bool isScanning = false;
  String? errorMessage;

  @override
  void dispose() {
    domainController.dispose();
    super.dispose();
  }

  Future<void> startScan() async {
    String domain = domainController.text.trim();

    if (domain.isEmpty) {
      setState(() {
        errorMessage = "Please enter a domain or IP address";
      });
      return;
    }

    setState(() {
      isScanning = true;
      errorMessage = null;
    });

    try {
      await apiService.scanTarget(domain);

      if (!mounted) return;

      // Scan succeeded and was saved on the backend - go back to
      // the dashboard so it can reload its list.
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        isScanning = false;
        errorMessage = "Scan failed. Check the domain and try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Target')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter a domain or IP address to scan',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: domainController,
              enabled: !isScanning,
              decoration: const InputDecoration(
                hintText: 'e.g. example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!isScanning) {
                  startScan();
                }
              },
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 24),
            if (isScanning)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LoadingSpinner(message: 'Scanning target...'),
              )
            else
              ElevatedButton(
                onPressed: startScan,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Start Scan', style: TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}