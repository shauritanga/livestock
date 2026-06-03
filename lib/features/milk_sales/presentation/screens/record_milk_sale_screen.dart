import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/milk_inventory/presentation/providers/milk_inventory_providers.dart';
import 'package:livestock/features/milk_sales/domain/entities/milk_sale.dart';
import 'package:livestock/features/milk_sales/presentation/providers/milk_sale_providers.dart';
import 'package:livestock/features/off_takers/presentation/providers/off_taker_providers.dart';

/// Screen for recording a milk sale
class RecordMilkSaleScreen extends ConsumerStatefulWidget {
  const RecordMilkSaleScreen({super.key});

  @override
  ConsumerState<RecordMilkSaleScreen> createState() => _RecordMilkSaleScreenState();
}

class _RecordMilkSaleScreenState extends ConsumerState<RecordMilkSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _customerNameController = TextEditingController();

  String? _selectedOffTakerId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  double get totalAmount {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    return quantity * price;
  }

  @override
  Widget build(BuildContext context) {
    final availableQuantityAsync = ref.watch(totalAvailableQuantityProvider);
    final activeOffTakersAsync = ref.watch(activeOffTakersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Milk Sale'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Available inventory card
            availableQuantityAsync.when(
              data: (quantity) => Card(
                color: Colors.blue.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2, color: Colors.blue),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Inventory',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${quantity.toStringAsFixed(1)} Liters',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Off-Taker Selection
            activeOffTakersAsync.when(
              data: (offTakers) {
                if (offTakers.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedOffTakerId,
                      decoration: InputDecoration(
                        labelText: 'Off-Taker (Optional)',
                        hintText: 'Select an off-taker or leave blank',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.business),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('None (Walk-in customer)'),
                        ),
                        ...offTakers.map((offTaker) {
                          return DropdownMenuItem<String>(
                            value: offTaker.id,
                            child: Text(offTaker.businessName),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedOffTakerId = value;
                          if (value != null) {
                            final selectedOffTaker = offTakers.firstWhere(
                              (ot) => ot.id == value,
                            );
                            _customerNameController.text = selectedOffTaker.businessName;
                          } else {
                            _customerNameController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Quantity field
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity (Liters) *',
                hintText: 'Enter quantity in liters',
                prefixIcon: const Icon(Icons.water_drop),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                final quantity = double.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Quantity must be greater than 0';
                }
                
                // Check against available inventory
                final availableQuantity = availableQuantityAsync.value ?? 0;
                if (quantity > availableQuantity) {
                  return 'Insufficient inventory. Only ${availableQuantity.toStringAsFixed(1)}L available';
                }
                
                return null;
              },
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for total
              },
            ),
            const SizedBox(height: 16),

            // Price per liter field
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price per Liter (TZS) *',
                hintText: 'Enter price per liter',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixText: 'TZS ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter price';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Price must be greater than 0';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for total
              },
            ),
            const SizedBox(height: 16),

            // Total Amount Display
            Card(
              color: Colors.green.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'TZS ${NumberFormat('#,##0').format(totalAmount)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Customer Name field
            TextFormField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Optional',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                  : const Text(
                      'Record Sale',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(currentAuthUserProvider);
      if (user == null || user.cooperativeId == null) {
        throw Exception('User not authenticated');
      }

      final quantity = double.parse(_quantityController.text);
      final pricePerLiter = double.parse(_priceController.text);

      final sale = MilkSale(
        id: '',
        cooperativeId: user.cooperativeId!,
        offTakerId: _selectedOffTakerId,
        customerName: _customerNameController.text.isEmpty
            ? null
            : _customerNameController.text,
        quantityLiters: quantity,
        pricePerLiter: pricePerLiter,
        totalAmount: quantity * pricePerLiter,
        saleDate: DateTime.now(),
        recordedBy: user.uid,
        createdAt: DateTime.now(),
      );

      final useCase = ref.read(recordMilkSaleUseCaseProvider);
      await useCase(sale);

      if (mounted) {
        // Refresh providers
        ref.invalidate(totalAvailableQuantityProvider);
        ref.invalidate(currentMilkInventoryProvider);
        ref.invalidate(milkSalesProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Milk sale recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
