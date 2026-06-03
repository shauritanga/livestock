import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livestock/core/utils/validators.dart';

/// Step widget for farmer location and cattle information
class FarmerLocationStep extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController totalCattleController;
  final TextEditingController lactatingCattleController;

  const FarmerLocationStep({
    super.key,
    required this.locationController,
    required this.totalCattleController,
    required this.lactatingCattleController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location & Cattle Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Provide location and herd details',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: locationController,
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
          validator: (value) => Validators.validateRequired(value, 'Location'),
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Icon(Icons.pets, size: 20, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Cattle Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: totalCattleController,
                decoration: InputDecoration(
                  labelText: 'Total Cattle *',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.format_list_numbered),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: lactatingCattleController,
                decoration: InputDecoration(
                  labelText: 'Lactating *',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.water_drop),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                  final total =
                      int.tryParse(totalCattleController.text) ?? 0;
                  if (number > total) {
                    return 'Cannot exceed total';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Lactating cattle are those currently producing milk',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
