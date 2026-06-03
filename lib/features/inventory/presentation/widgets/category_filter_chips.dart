import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/features/inventory/domain/entities/product_category.dart';
import 'package:livestock/features/inventory/presentation/providers/inventory_providers.dart';

/// Category filter chips widget
class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }
}
