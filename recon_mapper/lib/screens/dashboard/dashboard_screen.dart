//-------------------------------------------------------------------------------------
// Home screen: shows all saved targets fetched from GET /targets.
// FAB : AddTargetScreen. When it pops with result=true, reload the list.
//-------------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/target.dart';
import '../../widgets/target_card.dart';
import '../../widgets/loading_spinner.dart';
import '../add_target/add_target_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();

  List<Target> _targets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  //----------------------------------------------------------
  // Fetches all targets from the backend and updates state.
  //----------------------------------------------------------
  Future<void> _loadTargets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final targets = await _api.getTargets();
      setState(() {
        _targets = targets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Could not load targets.\nMake sure the backend is running.';
      });
    }
  }

  //----------------------------------------------------------
  // Opens AddTargetScreen. Reloads list if a scan was saved.
  //----------------------------------------------------------
  Future<void> _goToAddTarget() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddTargetScreen()),
    );

    if (result == true) {
      _loadTargets(); // refresh after new scan
    }
  }

  //----------------------------------------------------------
  // Body: loading / error / empty / list
  //----------------------------------------------------------
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingSpinner(message: 'Loading targets...');
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadTargets,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_targets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.radar, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No targets yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to scan your first domain.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTargets, // pull-to-refresh
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _targets.length,
        itemBuilder: (context, index) => TargetCard(target: _targets[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReconMapper'),
        actions: [
          // Manual refresh button in the top-right
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadTargets,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddTarget,
        tooltip: 'Scan new target',
        child: const Icon(Icons.add),
      ),
    );
  }
}

