import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Step 3: Cattle Information (Detailed as per Requirement 2)
class CattleInfoStepScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onBack;
  final Map<String, dynamic> initialData;

  const CattleInfoStepScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.initialData,
  });

  @override
  State<CattleInfoStepScreen> createState() => _CattleInfoStepScreenState();
}

class _CattleInfoStepScreenState extends State<CattleInfoStepScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _totalCattleController;
  late final TextEditingController _lactatingCattleController;

  @override
  void initState() {
    super.initState();
    _totalCattleController = TextEditingController(
        text: widget.initialData['totalCattle']?.toString() ?? '0');
    _lactatingCattleController = TextEditingController(
        text: widget.initialData['lactatingCattle']?.toString() ?? '0');
  }

  @override
  void dispose() {
    _totalCattleController.dispose();
    _lactatingCattleController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.onNext({
        'totalCattle': int.tryParse(_totalCattleController.text) ?? 0,
        'lactatingCattle': int.tryParse(_lactatingCattleController.text) ?? 0,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(
                Icons.pets,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'Cattle Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Provide initial herd details',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Detailed cattle records (gender, age, breed, lactation status, health status, acquisition date) will be captured later when registering individual cattle with biometric IDs.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _totalCattleController,
                decoration: InputDecoration(
                  labelText: 'Total Cattle *',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.format_list_numbered),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  helperText: 'Total number of cattle owned by the farmer',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 0) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lactatingCattleController,
                decoration: InputDecoration(
                  labelText: 'Lactating Cattle *',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.water_drop),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  helperText: 'Number of cattle currently producing milk',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 0) {
                    return 'Invalid number';
                  }
                  final total = int.tryParse(_totalCattleController.text) ?? 0;
                  if (number > total) {
                    return 'Cannot exceed total cattle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        const Text(
                          'What happens next?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint(
                        'Individual cattle will be registered with biometric IDs'),
                    _buildBulletPoint(
                        'Detailed info: gender, age, breed, lactation status'),
                    _buildBulletPoint(
                        'Health status and acquisition date will be recorded'),
                    _buildBulletPoint(
                        'Muzzle patterns captured for identification'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onBack,
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
                      onPressed: _handleNext,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Continue'),
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
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
