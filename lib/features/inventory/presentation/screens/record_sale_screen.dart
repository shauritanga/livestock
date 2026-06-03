import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:livestock/features/inventory/presentation/providers/sales_providers.dart';
import 'package:livestock/features/off_takers/presentation/providers/off_taker_providers.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Screen for recording a product sale
class RecordSaleScreen extends ConsumerStatefulWidget {
  const RecordSaleScreen({super.key});

  @override
  ConsumerState<RecordSaleScreen> createState() => _RecordSaleScreenState();
}

class _RecordSaleScreenState extends ConsumerState<RecordSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();

  String? _selectedProductId;
  String? _selectedOffTakerId;
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _customerNameController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  double get totalAmount {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    return quantity * unitPrice;
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final selectedProduct = _selectedProductId != null
        ? ref.watch(productByIdProvider(_selectedProductId!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Sale'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Selection
            if (_selectedProductId == null) ...[
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Product',
                  hintText: 'Search by name or SKU',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).setQuery(value);
                },
              ),
              const SizedBox(height: 16),

              // Product List
              productsAsync.when(
                data: (products) {
                  final availableProducts =
                      products.where((p) => !p.isOutOfStock).toList();

                  if (availableProducts.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No products available for sale'),
                      ),
                    );
                  }

                  return Column(
                    children: availableProducts.map((product) {
                      return Card(
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                            '${product.currentStock.toStringAsFixed(1)} ${product.unitOfMeasure} available',
                          ),
                          trailing: Text(
                            'TZS ${NumberFormat('#,##0').format(product.unitPrice)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedProductId = product.id;
                              _unitPriceController.text =
                                  product.unitPrice.toString();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              ),
            ] else ...[
              // Selected Product Card
              selectedProduct?.when(
                    data: (product) {
                      if (product == null) return const SizedBox.shrink();

                      return Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Available: ${product.currentStock.toStringAsFixed(1)} ${product.unitOfMeasure}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedProductId = null;
                                        _quantityController.clear();
                                        _unitPriceController.clear();
                                      });
                                    },
                                    child: const Text('Change'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error loading product'),
                  ) ??
                  const SizedBox.shrink(),
              const SizedBox(height: 24),

              // Off-Taker Selection (Optional)
              Consumer(
                builder: (context, ref, child) {
                  final activeOffTakersAsync = ref.watch(activeOffTakersProvider);
                  
                  return activeOffTakersAsync.when(
                    data: (offTakers) {
                      if (offTakers.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedOffTakerId,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).selectOffTaker,
                              hintText: 'Select an off-taker or leave blank',
                              border: const OutlineInputBorder(),
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
                                // Auto-fill customer name if off-taker selected
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
                  );
                },
              ),

              // Sale Details Form
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity *',
                  hintText: 'Enter quantity',
                  border: const OutlineInputBorder(),
                  suffixText: selectedProduct?.value?.unitOfMeasure ?? '',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Quantity is required';
                  }
                  final quantity = double.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Quantity must be a positive number';
                  }
                  final product = selectedProduct?.value;
                  if (product != null && quantity > product.currentStock) {
                    return 'Insufficient stock. Only ${product.currentStock} available';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild for total
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _unitPriceController,
                decoration: const InputDecoration(
                  labelText: 'Unit Price (TZS) *',
                  hintText: 'Enter unit price',
                  border: OutlineInputBorder(),
                  prefixText: 'TZS ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Unit price is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Unit price must be a positive number';
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
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'TZS ${NumberFormat('#,##0').format(totalAmount)}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  hintText: 'Optional',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.length > 100) {
                    return 'Customer name must not exceed 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Optional notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'Notes must not exceed 500 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Record Sale Button
              ElevatedButton(
                onPressed: _isLoading ? null : _recordSale,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Record Sale'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _recordSale() async {
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(currentAuthUserProvider);
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final useCase = await ref.read(recordSaleUseCaseProvider.future);
      await useCase(
        cooperativeId: user.cooperativeId!,
        productId: _selectedProductId!,
        quantity: double.parse(_quantityController.text),
        unitPrice: double.parse(_unitPriceController.text),
        customerName: _customerNameController.text.isEmpty
            ? null
            : _customerNameController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        processedBy: user.uid,
      );

      if (mounted) {
        ref.invalidate(salesProvider);
        ref.invalidate(productsProvider);
        ref.invalidate(productByIdProvider(_selectedProductId!));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale recorded successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
