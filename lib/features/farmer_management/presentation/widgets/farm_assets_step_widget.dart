import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Step widget for farm assets information
class FarmAssetsStepWidget extends StatelessWidget {
  final TextEditingController avocadoTotalController;
  final TextEditingController avocadoFruitingController;
  final TextEditingController femaleChickensController;
  final TextEditingController roostersController;
  final TextEditingController maleCattleController;
  final TextEditingController femaleCattleController;
  final TextEditingController largeBeehivesController;
  final TextEditingController smallBeehivesController;
  final TextEditingController bananaPlantsController;
  final TextEditingController passionSeedlingsController;
  final TextEditingController potatoHectaresController;
  final DateTime? potatoPlantingDate;
  final Function(DateTime?) onPotatoPlantingDateChanged;

  const FarmAssetsStepWidget({
    super.key,
    required this.avocadoTotalController,
    required this.avocadoFruitingController,
    required this.femaleChickensController,
    required this.roostersController,
    required this.maleCattleController,
    required this.femaleCattleController,
    required this.largeBeehivesController,
    required this.smallBeehivesController,
    required this.bananaPlantsController,
    required this.passionSeedlingsController,
    required this.potatoHectaresController,
    required this.potatoPlantingDate,
    required this.onPotatoPlantingDateChanged,
  });

  String? _validateNonNegativeInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < 0) {
      return '$fieldName cannot be negative';
    }

    return null;
  }

  String? _validateDecimal(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < 0) {
      return 'Hectares cannot be negative';
    }

    if (number > 1000) {
      return 'Hectares cannot exceed 1000';
    }

    return null;
  }

  String? _validateAvocadoFruiting(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final fruiting = int.tryParse(value);
    final total = int.tryParse(avocadoTotalController.text);

    if (fruiting == null) {
      return 'Please enter a valid number';
    }

    if (fruiting < 0) {
      return 'Cannot be negative';
    }

    if (total != null && fruiting > total) {
      return 'Cannot exceed total avocado trees';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farm Assets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter details about the farmer\'s agricultural assets (all fields are optional)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Avocado Section
          _buildSectionHeader(Icons.eco, 'Avocado Trees', Colors.green),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: avocadoTotalController,
                  decoration: InputDecoration(
                    labelText: 'Total Trees',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.park),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      _validateNonNegativeInteger(value, 'Total trees'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: avocadoFruitingController,
                  decoration: InputDecoration(
                    labelText: 'Fruiting Trees',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.spa),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validateAvocadoFruiting,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Poultry Section
          _buildSectionHeader(Icons.egg, 'Poultry', Colors.orange),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: femaleChickensController,
                  decoration: InputDecoration(
                    labelText: 'Female Chickens',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.egg_alt),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      _validateNonNegativeInteger(value, 'Female chickens'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: roostersController,
                  decoration: InputDecoration(
                    labelText: 'Roosters',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.cruelty_free),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      _validateNonNegativeInteger(value, 'Roosters'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Cattle Section
          _buildSectionHeader(Icons.pets, 'Cattle', Colors.brown),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: maleCattleController,
                  decoration: InputDecoration(
                    labelText: 'Male Cattle (Bulls)',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.male),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      _validateNonNegativeInteger(value, 'Male cattle'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: femaleCattleController,
                  decoration: InputDecoration(
                    labelText: 'Female Cattle (Cows)',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.female),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      _validateNonNegativeInteger(value, 'Female cattle'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Beekeeping Section
          _buildSectionHeader(Icons.hive, 'Beekeeping', Colors.amber),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: largeBeehivesController,
                  decoration: InputDecoration(
                    labelText: 'Large Modern Beehives',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.home_work),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      _validateNonNegativeInteger(value, 'Large beehives'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: smallBeehivesController,
                  decoration: InputDecoration(
                    labelText: 'Small/Traditional Beehives',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.home),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      _validateNonNegativeInteger(value, 'Small beehives'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Crops Section
          _buildSectionHeader(Icons.agriculture, 'Crops', Colors.lightGreen),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: bananaPlantsController,
                  decoration: InputDecoration(
                    labelText: 'Banana Plants',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.nature),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      _validateNonNegativeInteger(value, 'Banana plants'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: passionSeedlingsController,
                  decoration: InputDecoration(
                    labelText: 'Passion Fruit Seedlings',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.local_florist),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      _validateNonNegativeInteger(value, 'Passion seedlings'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Potatoes Section
          _buildSectionHeader(Icons.grass, 'Potatoes', Colors.deepOrange),
          const SizedBox(height: 12),
          TextFormField(
            controller: TextEditingController(
              text: potatoPlantingDate == null
                  ? ''
                  : DateFormat('dd/MM/yyyy').format(potatoPlantingDate!),
            ),
            decoration: InputDecoration(
              labelText: 'Planting Date',
              hintText: 'Select planting date',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            readOnly: true,
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: potatoPlantingDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2030),
                helpText: 'Select Planting Date',
              );
              if (selectedDate != null) {
                onPotatoPlantingDateChanged(selectedDate);
              }
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: potatoHectaresController,
            decoration: InputDecoration(
              labelText: 'Farm Size (Hectares)',
              hintText: '0.0',
              prefixIcon: const Icon(Icons.landscape),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              helperText: 'Enter size in hectares (e.g., 2.5)',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: _validateDecimal,
          ),
          const SizedBox(height: 16),

          // Info box
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
                    'All farm asset fields are optional. Enter 0 or leave blank if not applicable.',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
