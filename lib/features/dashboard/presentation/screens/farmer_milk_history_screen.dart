import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_collection/presentation/providers/milk_collection_providers.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Farmer Milk History Screen - Shows all milk deliveries for the farmer
class FarmerMilkHistoryScreen extends ConsumerStatefulWidget {
  const FarmerMilkHistoryScreen({super.key});

  @override
  ConsumerState<FarmerMilkHistoryScreen> createState() => _FarmerMilkHistoryScreenState();
}

class _FarmerMilkHistoryScreenState extends ConsumerState<FarmerMilkHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPeriod = 'all'; // all, month, week, custom

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAuthUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).milkHistory),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          _PeriodSelector(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (period) {
              setState(() {
                _selectedPeriod = period;
                _updateDateRange(period);
              });
            },
          ),
          
          // Deliveries list
          Expanded(
            child: _DeliveriesList(
              farmerId: user?.uid ?? '',
              cooperativeId: user?.cooperativeId ?? '',
              startDate: _startDate,
              endDate: _endDate,
            ),
          ),
        ],
      ),
    );
  }

  void _updateDateRange(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'week':
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case 'month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'all':
      default:
        _startDate = null;
        _endDate = null;
        break;
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).filterByDate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context).startDate),
              subtitle: Text(
                _startDate != null
                    ? DateFormat('MMM d, yyyy').format(_startDate!)
                    : AppLocalizations.of(context).notSet,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                    _selectedPeriod = 'custom';
                  });
                }
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).endDate),
              subtitle: Text(
                _endDate != null
                    ? DateFormat('MMM d, yyyy').format(_endDate!)
                    : AppLocalizations.of(context).notSet,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _endDate = date;
                    _selectedPeriod = 'custom';
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
                _selectedPeriod = 'all';
              });
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).clear),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).apply),
          ),
        ],
      ),
    );
  }
}

/// Period selector widget
class _PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _PeriodChip(
              label: AppLocalizations.of(context).allTime,
              isSelected: selectedPeriod == 'all',
              onTap: () => onPeriodChanged('all'),
            ),
            const SizedBox(width: 8),
            _PeriodChip(
              label: AppLocalizations.of(context).thisMonth,
              isSelected: selectedPeriod == 'month',
              onTap: () => onPeriodChanged('month'),
            ),
            const SizedBox(width: 8),
            _PeriodChip(
              label: AppLocalizations.of(context).lastWeek,
              isSelected: selectedPeriod == 'week',
              onTap: () => onPeriodChanged('week'),
            ),
            const SizedBox(width: 8),
            _PeriodChip(
              label: AppLocalizations.of(context).custom,
              isSelected: selectedPeriod == 'custom',
              onTap: () => onPeriodChanged('custom'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Period chip widget
class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}

/// Deliveries list widget
class _DeliveriesList extends ConsumerWidget {
  final String farmerId;
  final String cooperativeId;
  final DateTime? startDate;
  final DateTime? endDate;

  const _DeliveriesList({
    required this.farmerId,
    required this.cooperativeId,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create a provider for filtered deliveries
    final deliveriesAsync = ref.watch(
      farmerDeliveriesProvider((farmerId, cooperativeId, startDate, endDate)),
    );

    return deliveriesAsync.when(
      data: (deliveries) {
        if (deliveries.isEmpty) {
          return _EmptyState(
            icon: Icons.water_drop,
            message: AppLocalizations.of(context).noDeliveriesFound,
          );
        }

        // Group deliveries by month
        final groupedDeliveries = _groupDeliveriesByMonth(deliveries);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedDeliveries.length,
          itemBuilder: (context, index) {
            final monthKey = groupedDeliveries.keys.elementAt(index);
            final monthDeliveries = groupedDeliveries[monthKey]!;
            
            return _MonthSection(
              monthKey: monthKey,
              deliveries: monthDeliveries,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => _EmptyState(
        icon: Icons.error_outline,
        message: AppLocalizations.of(context).errorLoadingDeliveries,
      ),
    );
  }

  Map<String, List<MilkDelivery>> _groupDeliveriesByMonth(List<MilkDelivery> deliveries) {
    final Map<String, List<MilkDelivery>> grouped = {};
    
    for (final delivery in deliveries) {
      final monthKey = DateFormat('MMMM yyyy').format(delivery.deliveryDate);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(delivery);
    }
    
    return grouped;
  }
}

/// Month section widget
class _MonthSection extends StatelessWidget {
  final String monthKey;
  final List<MilkDelivery> deliveries;

  const _MonthSection({
    required this.monthKey,
    required this.deliveries,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate monthly totals
    double totalLiters = 0.0;
    double totalPayment = 0.0;
    
    for (final delivery in deliveries) {
      totalLiters += delivery.quantityLiters;
      totalPayment += delivery.totalAmount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header with summary
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthKey,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${totalLiters.toStringAsFixed(1)}L',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    'TZS ${NumberFormat('#,##0', 'en_US').format(totalPayment)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Deliveries list
        ...deliveries.map((delivery) => _DeliveryCard(delivery: delivery)),
        
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Delivery card widget
class _DeliveryCard extends StatelessWidget {
  final MilkDelivery delivery;

  const _DeliveryCard({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Date circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getQualityColor(delivery.qualityGrade).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(delivery.deliveryDate),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getQualityColor(delivery.qualityGrade),
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(delivery.deliveryDate),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getQualityColor(delivery.qualityGrade),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Delivery details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${delivery.quantityLiters.toStringAsFixed(1)} Liters',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getQualityColor(delivery.qualityGrade).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getQualityLabel(delivery.qualityGrade),
                          style: TextStyle(
                            fontSize: 11,
                            color: _getQualityColor(delivery.qualityGrade),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(delivery.deliveryDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'TZS ${NumberFormat('#,##0', 'en_US').format(delivery.totalAmount)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getQualityColor(dynamic qualityGrade) {
    final grade = qualityGrade.toString().split('.').last.toLowerCase();
    switch (grade) {
      case 'premium':
        return Colors.green;
      case 'standard':
        return Colors.blue;
      case 'substandard':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getQualityLabel(dynamic qualityGrade) {
    final grade = qualityGrade.toString().split('.').last;
    return grade[0].toUpperCase() + grade.substring(1);
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Provider for farmer deliveries with date filtering
final farmerDeliveriesProvider = FutureProvider.family<List<MilkDelivery>, (String, String, DateTime?, DateTime?)>(
  (ref, params) async {
    final (farmerId, cooperativeId, startDate, endDate) = params;
    
    if (farmerId.isEmpty || cooperativeId.isEmpty) {
      return [];
    }

    final repository = ref.watch(milkDeliveryRepositoryProvider);
    final user = ref.watch(currentAuthUserProvider);
    
    if (user == null) {
      return [];
    }
    
    if (startDate != null && endDate != null) {
      final result = await repository.getDeliveryHistory(
        farmerId,
        startDate: startDate,
        endDate: endDate,
      );
      
      return result.fold(
        onError: (failure) => [],
        onSuccess: (deliveries) => deliveries,
      );
    } else {
      // Get all deliveries (last 6 months as default)
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
      
      final result = await repository.getDeliveryHistory(
        farmerId,
        startDate: sixMonthsAgo,
        endDate: now,
      );
      
      return result.fold(
        onError: (failure) => [],
        onSuccess: (deliveries) => deliveries,
      );
    }
  },
);
