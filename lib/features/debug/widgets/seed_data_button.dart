import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class SeedDataButton extends StatefulWidget {
  const SeedDataButton({super.key});

  @override
  State<SeedDataButton> createState() => _SeedDataButtonState();
}

class _SeedDataButtonState extends State<SeedDataButton> {
  bool _isSeeding = false;
  String _status = '';

  Future<void> _seedDatabase() async {
    setState(() {
      _isSeeding = true;
      _status = 'Starting...';
    });

    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');

      // Step 1: Seed test data (cooperatives, farmers, cattle, etc.)
      setState(() => _status = 'Creating cooperatives, farmers, and cattle...');
      await functions.httpsCallable('seedTestData').call();
      
      // Step 2: Seed premium rates
      setState(() => _status = 'Creating insurance premium rates...');
      await functions.httpsCallable('seedPremiumRates').call();
      
      // Step 3: Seed milk deliveries
      setState(() => _status = 'Creating milk delivery records...');
      await functions.httpsCallable('seedMilkDeliveries').call();
      
      setState(() {
        _status = 'Database seeded successfully! ✓';
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database seeded successfully! Restart the app to see analytics.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to seed database: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seed Test Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'This will populate your database with test data including:\n'
              '• Cooperatives and collection centres\n'
              '• Farmers and cattle\n'
              '• Milk delivery records\n'
              '• Insurance premium rates',
            ),
            const SizedBox(height: 16),
            if (_status.isNotEmpty) ...[
              Text(
                _status,
                style: TextStyle(
                  color: _status.contains('Error') ? Colors.red : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],
            ElevatedButton.icon(
              onPressed: _isSeeding ? null : _seedDatabase,
              icon: _isSeeding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isSeeding ? 'Seeding...' : 'Seed Database'),
            ),
          ],
        ),
      ),
    );
  }
}
