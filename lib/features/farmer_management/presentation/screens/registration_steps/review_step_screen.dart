import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_registration_state_provider.dart';

/// Step 5: Review and Submit
class ReviewStepScreen extends ConsumerWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onBack;
  final Future<void> Function() onSubmit;

  const ReviewStepScreen({
    super.key,
    required this.formData,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(farmerRegistrationProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Review Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please review the information before submitting',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildSection(
              'Personal Information',
              Icons.person,
              [
                _buildInfoRow('Name', formData['name'] ?? 'N/A'),
                _buildInfoRow('Phone', formData['phoneNumber'] ?? 'N/A'),
                if (formData['email'] != null && formData['email'].isNotEmpty)
                  _buildInfoRow('Email', formData['email']),
                _buildInfoRow('National ID', formData['nationalId'] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Location',
              Icons.location_on,
              [
                _buildInfoRow('Location', formData['location'] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Cattle Information',
              Icons.pets,
              [
                _buildInfoRow('Total Cattle',
                    formData['totalCattle']?.toString() ?? '0'),
                _buildInfoRow('Lactating Cattle',
                    formData['lactatingCattle']?.toString() ?? '0'),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              'App Access',
              Icons.smartphone,
              [
                _buildInfoRow(
                  'Mobile App Access',
                  formData['hasAppAccess'] == true ? 'Enabled' : 'Disabled',
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (state.isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onSubmit,
                      icon: const Icon(Icons.check),
                      label: const Text('Register Farmer'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.green),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
