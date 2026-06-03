import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_list_state_provider.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_collection/presentation/providers/milk_collection_providers.dart';
import 'package:livestock/l10n/app_localizations.dart';

enum CollectionTime { morning, evening }

/// Screen for recording milk collection
class MilkCollectionScreen extends ConsumerStatefulWidget {
  final Farmer? farmer;

  const MilkCollectionScreen({
    super.key,
    this.farmer,
  });

  @override
  ConsumerState<MilkCollectionScreen> createState() =>
      _MilkCollectionScreenState();
}

class _MilkCollectionScreenState extends ConsumerState<MilkCollectionScreen> {
  final _formKey = GlobalKey<FormState>();

  Farmer? _selectedFarmer;
  double? _selectedQuantity;
  final _manualQuantityController = TextEditingController();
  bool _useManualEntry = false;
  bool _isSubmitting = false;
  DateTime _selectedDate = DateTime.now();
  CollectionTime _collectionTime = CollectionTime.morning;

  // Predefined quantities from 0.5L to 15L in 0.5L increments
  final List<double> _predefinedQuantities = List.generate(
    30,
    (index) => (index + 1) * 0.5,
  );

  @override
  void initState() {
    super.initState();
    // If farmer is provided, use it
    _selectedFarmer = widget.farmer;
    
    // Load farmers if not provided
    if (widget.farmer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadFarmers();
      });
    }
  }

  void _loadFarmers() {
    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    // Load farmers by cooperative (collection centres removed)
    if (user.cooperativeId != null) {
      ref.read(farmerListProvider.notifier).loadFarmersByCooperative(
            user.cooperativeId!,
          );
    }
  }

  @override
  void dispose() {
    _manualQuantityController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = _useManualEntry
        ? double.parse(_manualQuantityController.text)
        : _selectedQuantity!;

    final user = ref.read(currentAuthUserProvider);
    if (user == null) {
      return;
    }

    if (_selectedFarmer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a farmer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Combine selected date with collection time
    final deliveryDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _collectionTime == CollectionTime.morning ? 6 : 18, // 6 AM or 6 PM
    );

    final delivery = MilkDelivery(
      id: '',
      farmerId: _selectedFarmer!.id,
      cooperativeId: _selectedFarmer!.cooperativeId,
      quantityLiters: quantity,
      qualityGrade: MilkQualityGrade.standard,
      deliveryDate: deliveryDateTime,
      recordedBy: user.uid,
      createdAt: DateTime.now(),
      paymentBatchId: null, // Unpaid initially
    );

    final result =
        await ref.read(recordDeliveryUseCaseProvider).call(delivery);

    setState(() {
      _isSubmitting = false;
    });

    switch (result) {
      case Success():
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Delivery recorded: ${quantity.toStringAsFixed(1)} liters',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          // Pop once to return to milk collection main screen
          Navigator.of(context).pop(true);
        }
      case Error(:final failure):
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to record delivery: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
    }
  }

  Future<void> _selectDate() async {
    final l10n = AppLocalizations.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      helpText: l10n.selectDate,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Milk Collection'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Farmer selection dropdown (if farmer not pre-selected)
            if (widget.farmer == null) ...[
              const Text(
                'Select Farmer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildFarmerDropdown(),
              const SizedBox(height: 24),
            ],

            // Farmer info card (if farmer is selected)
            if (_selectedFarmer != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Farmer',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedFarmer!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedFarmer!.phoneNumber,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            
            if (_selectedFarmer != null) const SizedBox(height: 24),

            // Date selection
            Text(
              l10n.collectionDate,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  dateFormat.format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Collection time selection
            Text(
              l10n.collectionTime,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<CollectionTime>(
                    title: Text(l10n.morning),
                    value: CollectionTime.morning,
                    groupValue: _collectionTime,
                    onChanged: (value) {
                      setState(() {
                        _collectionTime = value!;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _collectionTime == CollectionTime.morning
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RadioListTile<CollectionTime>(
                    title: Text(l10n.evening),
                    value: CollectionTime.evening,
                    groupValue: _collectionTime,
                    onChanged: (value) {
                      setState(() {
                        _collectionTime = value!;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _collectionTime == CollectionTime.evening
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quantity selection
            const Text(
              'Milk Quantity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              title: const Text('Manual Entry (> 15L)'),
              value: _useManualEntry,
              onChanged: (value) {
                setState(() {
                  _useManualEntry = value;
                  _selectedQuantity = null;
                });
              },
            ),

            if (!_useManualEntry) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<double>(
                decoration: const InputDecoration(
                  labelText: 'Select Quantity (Liters)',
                  prefixIcon: Icon(Icons.water_drop),
                ),
                initialValue: _selectedQuantity,
                items: _predefinedQuantities.map((quantity) {
                  return DropdownMenuItem(
                    value: quantity,
                    child: Text('${quantity.toStringAsFixed(1)} L'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedQuantity = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select quantity';
                  }
                  return null;
                },
              ),
            ] else ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _manualQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Enter Quantity (Liters)',
                  hintText: 'e.g., 20.5 (must be in 0.5L increments)',
                  prefixIcon: Icon(Icons.water_drop),
                  helperText: 'Enter in 0.5L increments (e.g., 16.0, 16.5, 17.0)',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final quantity = double.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  if (quantity <= 15) {
                    return 'Use dropdown for quantities ≤ 15L';
                  }
                  // Check if quantity is in 0.5L increments
                  final remainder = (quantity * 10) % 5;
                  if (remainder != 0) {
                    return 'Quantity must be in 0.5L increments (e.g., 16.0, 16.5, 17.0)';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Record Delivery'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerDropdown() {
    final state = ref.watch(farmerListProvider);

    if (state.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (state.errorMessage != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Error loading farmers: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _loadFarmers,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.farmers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No farmers found. Please register farmers first.'),
        ),
      );
    }

    return DropdownButtonFormField<Farmer>(
      decoration: InputDecoration(
        labelText: 'Select Farmer',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      initialValue: _selectedFarmer,
      items: state.farmers.map((farmer) {
        return DropdownMenuItem<Farmer>(
          value: farmer,
          child: Text(farmer.name),
        );
      }).toList(),
      onChanged: (farmer) {
        setState(() {
          _selectedFarmer = farmer;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a farmer';
        }
        return null;
      },
    );
  }
}
