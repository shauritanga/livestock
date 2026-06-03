import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';

/// Product search bar widget with filters
class ProductSearchBar extends ConsumerStatefulWidget {
  final Function(String)? onSearchChanged;
  final bool showFilters;

  const ProductSearchBar({
    super.key,
    this.onSearchChanged,
    this.showFilters = true,
  });

  @override
  ConsumerState<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends ConsumerState<ProductSearchBar> {
  final _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final stockFilter = ref.watch(stockStatusFilterProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    // Sync controller with provider
    if (_searchController.text != searchQuery) {
      _searchController.text = searchQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    final hasActiveFilters = selectedCategory != null || 
                            stockFilter != StockStatusFilter.all;

    return Column(
      children: [
        // Search Input
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or SKU',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).clear();
                        widget.onSearchChanged?.call('');
                      },
                    ),
                  if (widget.showFilters)
                    IconButton(
                      icon: Badge(
                        isLabelVisible: hasActiveFilters,
                        child: Icon(
                          _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                    ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).setQuery(value);
              widget.onSearchChanged?.call(value);
            },
          ),
        ),

        // Filters Section
        if (_showFilters && widget.showFilters) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Filter
                Row(
                  children: [
                    const Text(
                      'Category:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: selectedCategory == null,
                              onSelected: (selected) {
                                ref.read(selectedCategoryProvider.notifier).clear();
                              },
                            ),
                            const SizedBox(width: 8),
                            ...ProductCategory.values.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(category.displayName),
                                  selected: selectedCategory == category,
                                  onSelected: (selected) {
                                    ref
                                        .read(selectedCategoryProvider.notifier)
                                        .setCategory(selected ? category : null);
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Stock Status Filter
                Row(
                  children: [
                    const Text(
                      'Stock:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: stockFilter == StockStatusFilter.all,
                              onSelected: (selected) {
                                ref
                                    .read(stockStatusFilterProvider.notifier)
                                    .setFilter(StockStatusFilter.all);
                              },
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('In Stock'),
                              selected: stockFilter == StockStatusFilter.inStock,
                              onSelected: (selected) {
                                ref
                                    .read(stockStatusFilterProvider.notifier)
                                    .setFilter(StockStatusFilter.inStock);
                              },
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Low Stock'),
                              selected: stockFilter == StockStatusFilter.lowStock,
                              onSelected: (selected) {
                                ref
                                    .read(stockStatusFilterProvider.notifier)
                                    .setFilter(StockStatusFilter.lowStock);
                              },
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Out of Stock'),
                              selected: stockFilter == StockStatusFilter.outOfStock,
                              onSelected: (selected) {
                                ref
                                    .read(stockStatusFilterProvider.notifier)
                                    .setFilter(StockStatusFilter.outOfStock);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Clear Filters Button
                if (hasActiveFilters)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () {
                        ref.read(selectedCategoryProvider.notifier).clear();
                        ref
                            .read(stockStatusFilterProvider.notifier)
                            .setFilter(StockStatusFilter.all);
                      },
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear Filters'),
                    ),
                  ),
              ],
            ),
          ),
        ],

        // Result Count
        if (searchQuery.isNotEmpty || hasActiveFilters)
          Consumer(
            builder: (context, ref, child) {
              final productsAsync = ref.watch(productsProvider);
              return productsAsync.when(
                data: (products) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      '${products.length} ${products.length == 1 ? 'product' : 'products'} found',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
      ],
    );
  }
}
