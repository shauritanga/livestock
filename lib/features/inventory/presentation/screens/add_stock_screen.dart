import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/presentation/providers/stock_transaction_providers.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';

/// Screen for adding stock to a product
class AddStockScreen extends ConsumerStatefulWidget {
  final Product product;

  const AddStockScreen({super.key, required this.product});

  @override
  ConsumerState<AddStockScreen> createState() => _AddStockScreenState();
}

class _AddStockScreenState extends ConsumerState<AddStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  double get newStockLevel {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    return widget.product.currentStock + quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Stock'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Stock: ${widget.product.currentStock.toStringAsFixed(1)} ${widget.product.unitOfMeasure}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quantity Input
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity to Add *',
                hintText: 'Enter quantity',
                border: const OutlineInputBorder(),
                suffixText: widget.product.unitOfMeasure,
              ),
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.headlineSmall,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Quantity is required';
                }
                final quantity = double.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Quantity must be a positive number';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for preview
              },
            ),
            const SizedBox(height: 16),

            // Reason/Notes
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason/Notes',
                hintText: 'Optional notes about this stock addition',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Preview Section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Stock Level',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.product.currentStock.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.add, size: 32),
                        ),
                        Text(
                          _quantityController.text.isEmpty
                              ? '0'
                              : _quantityController.text,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.arrow_forward, size: 32),
                        ),
                        Text(
                          newStockLevel.toStringAsFixed(1),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _addStock,
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
                  : const Text('Add Stock'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addStock() async {
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

      final useCase = await ref.read(addStockUseCaseProvider.future);
      await useCase(
        cooperativeId: user.cooperativeId!,
        productId: widget.product.id,
        quantity: double.parse(_quantityController.text),
        reason: _reasonController.text.isEmpty ? null : _reasonController.text,
        performedBy: user.uid,
      );

      if (mounted) {
        ref.invalidate(productByIdProvider(widget.product.id));
        ref.invalidate(productsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock added successfully')),
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
