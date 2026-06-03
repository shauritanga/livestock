import 'package:flutter/material.dart';
import 'package:livestock/core/utils/validators.dart';

/// Step 2: Location Information
class LocationStepScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onBack;
  final Map<String, dynamic> initialData;

  const LocationStepScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.initialData,
  });

  @override
  State<LocationStepScreen> createState() => _LocationStepScreenState();
}

class _LocationStepScreenState extends State<LocationStepScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _locationController =
        TextEditingController(text: widget.initialData['location'] ?? '');
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.onNext({
        'location': _locationController.text.trim(),
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
                Icons.location_on,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Where is the farmer located?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location *',
                  hintText: 'Village, Ward, District',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  helperText: 'Physical location for service delivery',
                ),
                validator: (value) =>
                    Validators.validateRequired(value, 'Location'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Provide the farmer\'s physical location for record keeping and service delivery.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
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
}
