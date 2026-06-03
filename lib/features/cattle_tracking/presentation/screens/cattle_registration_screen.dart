import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/cattle_tracking/presentation/providers/cattle_registration_state_provider.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';

/// Screen for registering a new cattle
class CattleRegistrationScreen extends ConsumerStatefulWidget {
  final Farmer farmer;

  const CattleRegistrationScreen({
    super.key,
    required this.farmer,
  });

  @override
  ConsumerState<CattleRegistrationScreen> createState() =>
      _CattleRegistrationScreenState();
}

class _CattleRegistrationScreenState
    extends ConsumerState<CattleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  CattleGender _gender = CattleGender.female;
  int _ageMonths = 12;
  String _breed = '';
  LactationStatus _lactationStatus = LactationStatus.dry;
  String _healthStatus = 'Healthy';
  DateTime _acquisitionDate = DateTime.now();

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    final cattle = Cattle(
      id: '',
      farmerId: widget.farmer.id,
      cooperativeId: widget.farmer.cooperativeId,
      gender: _gender,
      ageMonths: _ageMonths,
      breed: _breed,
      lactationStatus: _lactationStatus,
      healthStatus: _healthStatus,
      acquisitionDate: _acquisitionDate,
      averageDailyProduction: 0.0,
    );

    await ref.read(cattleRegistrationProvider.notifier).registerCattle(cattle);

    final state = ref.read(cattleRegistrationProvider);

    if (state.registeredCattle != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cattle registered successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(state.registeredCattle);
    } else if (state.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cattleRegistrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Cattle'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Farmer info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Farmer',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.farmer.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Gender
            const Text(
              'Gender',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<CattleGender>(
              segments: const [
                ButtonSegment(
                  value: CattleGender.female,
                  label: Text('Female'),
                  icon: Icon(Icons.female),
                ),
                ButtonSegment(
                  value: CattleGender.male,
                  label: Text('Male'),
                  icon: Icon(Icons.male),
                ),
              ],
              selected: {_gender},
              onSelectionChanged: (Set<CattleGender> newSelection) {
                setState(() {
                  _gender = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),

            // Age
            Text(
              'Age: ${(_ageMonths / 12).toStringAsFixed(1)} years ($_ageMonths months)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _ageMonths.toDouble(),
              min: 1,
              max: 180,
              divisions: 179,
              label: '$_ageMonths months',
              onChanged: (value) {
                setState(() {
                  _ageMonths = value.toInt();
                });
              },
            ),
            const SizedBox(height: 16),

            // Breed
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Breed',
                hintText: 'e.g., Friesian, Ayrshire, Jersey',
                prefixIcon: Icon(Icons.pets),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Breed is required';
                }
                return null;
              },
              onSaved: (value) => _breed = value!,
            ),
            const SizedBox(height: 24),

            // Lactation Status
            const Text(
              'Lactation Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: LactationStatus.values.map((status) {
                return ChoiceChip(
                  label: Text(_getLactationStatusLabel(status)),
                  selected: _lactationStatus == status,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _lactationStatus = status;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Health Status
            TextFormField(
              initialValue: _healthStatus,
              decoration: const InputDecoration(
                labelText: 'Health Status',
                hintText: 'e.g., Healthy, Sick, Under Treatment',
                prefixIcon: Icon(Icons.health_and_safety),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Health status is required';
                }
                return null;
              },
              onSaved: (value) => _healthStatus = value!,
            ),
            const SizedBox(height: 24),

            // Acquisition Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Acquisition Date'),
              subtitle: Text(
                '${_acquisitionDate.day}/${_acquisitionDate.month}/${_acquisitionDate.year}',
              ),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _acquisitionDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _acquisitionDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: state.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Register Cattle'),
            ),
          ],
        ),
      ),
    );
  }

  String _getLactationStatusLabel(LactationStatus status) {
    switch (status) {
      case LactationStatus.lactating:
        return 'Lactating';
      case LactationStatus.dry:
        return 'Dry';
      case LactationStatus.pregnant:
        return 'Pregnant';
      case LactationStatus.calf:
        return 'Calf';
    }
  }
}
