import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/inventory/domain/entities/product.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';

/// Screen for adding or editing a product
class AddProductScreen extends ConsumerStatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _unitOfMeasureController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _initialStockController = TextEditingController();

  ProductCategory _selectedCategory = ProductCategory.other;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _skuController.text = widget.product!.sku;
      _unitOfMeasureController.text = widget.product!.unitOfMeasure;
      _unitPriceController.text = widget.product!.unitPrice.toString();
      _reorderPointController.text = widget.product!.reorderPoint.toString();
      _selectedCategory = widget.product!.category;
      _isActive = widget.product!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _unitOfMeasureController.dispose();
    _unitPriceController.dispose();
    _reorderPointController.dispose();
    _initialStockController.dispose();
    super.dispose();
  }

  bool get isEditMode => widget.product != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Product' : 'Add Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveProduct,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                hintText: 'Enter product name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Product name is required';
                }
                if (value.length < 2 || value.length > 100) {
                  return 'Name must be between 2 and 100 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // SKU
            TextFormField(
              controller: _skuController,
              decoration: InputDecoration(
                labelText: 'SKU *',
                hintText: 'Enter SKU',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.auto_awesome),
                  onPressed: _generateSKU,
                  tooltip: 'Generate SKU',
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'SKU is required';
                }
                if (!RegExp(r'^[a-zA-Z0-9-_]+$').hasMatch(value)) {
                  return 'SKU must contain only alphanumeric characters, hyphens, and underscores';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<ProductCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: ProductCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Unit of Measure
            DropdownButtonFormField<String>(
              value: _unitOfMeasureController.text.isEmpty
                  ? null
                  : _unitOfMeasureController.text,
              decoration: const InputDecoration(
                labelText: 'Unit of Measure *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'kg', child: Text('Kilograms (kg)')),
                DropdownMenuItem(value: 'liters', child: Text('Liters')),
                DropdownMenuItem(value: 'pieces', child: Text('Pieces')),
                DropdownMenuItem(value: 'bags', child: Text('Bags')),
                DropdownMenuItem(value: 'boxes', child: Text('Boxes')),
                DropdownMenuItem(value: 'bottles', child: Text('Bottles')),
                DropdownMenuItem(value: 'packets', child: Text('Packets')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _unitOfMeasureController.text = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Unit of measure is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Unit Price
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
            ),
            const SizedBox(height: 16),

            // Reorder Point
            TextFormField(
              controller: _reorderPointController,
              decoration: const InputDecoration(
                labelText: 'Reorder Point *',
                hintText: 'Minimum stock level',
                border: OutlineInputBorder(),
                helperText: 'Alert when stock reaches this level',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Reorder point is required';
                }
                final point = double.tryParse(value);
                if (point == null || point < 0) {
                  return 'Reorder point cannot be negative';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Initial Stock (only for new products)
            if (!isEditMode)
              TextFormField(
                controller: _initialStockController,
                decoration: const InputDecoration(
                  labelText: 'Initial Stock',
                  hintText: 'Enter initial stock quantity',
                  border: OutlineInputBorder(),
                  helperText: 'Optional: Leave empty for zero stock',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final stock = double.tryParse(value);
                    if (stock == null || stock < 0) {
                      return 'Initial stock cannot be negative';
                    }
                  }
                  return null;
                },
              ),

            // Active Status (only for edit mode)
            if (isEditMode) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active Status'),
                subtitle: Text(_isActive
                    ? 'Product is active and available'
                    : 'Product is inactive'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditMode ? 'Update Product' : 'Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  void _generateSKU() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter product name first')),
      );
      return;
    }

    final sku = name
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '')
        .substring(0, name.length > 8 ? 8 : name.length);
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    _skuController.text = '$sku-$timestamp';
  }

  Future<void> _saveProduct() async {
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

      final now = DateTime.now();
      final product = Product(
        id: widget.product?.id ?? now.millisecondsSinceEpoch.toString(),
        cooperativeId: user.cooperativeId ?? '',
        sku: _skuController.text.trim(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        unitOfMeasure: _unitOfMeasureController.text,
        unitPrice: double.parse(_unitPriceController.text),
        currentStock: isEditMode
            ? widget.product!.currentStock
            : (_initialStockController.text.isEmpty
                ? 0
                : double.parse(_initialStockController.text)),
        reorderPoint: double.parse(_reorderPointController.text),
        isActive: _isActive,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
        createdBy: widget.product?.createdBy ?? user.uid,
      );

      if (isEditMode) {
        final useCase = await ref.read(updateProductUseCaseProvider.future);
        await useCase(
          cooperativeId: user.cooperativeId!,
          product: product,
        );
      } else {
        final useCase = await ref.read(registerProductUseCaseProvider.future);
        await useCase(
          cooperativeId: user.cooperativeId!,
          product: product,
        );
      }

      if (mounted) {
        ref.invalidate(productsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? 'Product updated successfully'
                : 'Product added successfully'),
          ),
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
