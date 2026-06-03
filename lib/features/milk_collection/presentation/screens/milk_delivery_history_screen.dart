import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_collection/presentation/providers/milk_collection_providers.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Screen for viewing complete milk delivery history with filters
class MilkDeliveryHistoryScreen extends ConsumerStatefulWidget {
  final Farmer? farmer;

  const MilkDeliveryHistoryScreen({
    super.key,
    this.farmer,
  });

  @override
  ConsumerState<MilkDeliveryHistoryScreen> createState() =>
      _MilkDeliveryHistoryScreenState();
}

class _MilkDeliveryHistoryScreenState
    extends ConsumerState<MilkDeliveryHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPeriod = 'all'; // all, today, week, month, custom
  List<MilkDelivery> _deliveries = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDeliveries();
    });
  }

  Future<void> _loadDeliveries() async {
    if (widget.farmer == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Set date range based on selected period
    DateTime? startDate;
    DateTime? endDate;

    switch (_selectedPeriod) {
      case 'today':
        startDate = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
        endDate = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);
        break;
      case 'week':
        startDate = DateTime.now().subtract(const Duration(days: 7));
        endDate = DateTime.now();
        break;
      case 'month':
        startDate = DateTime.now().subtract(const Duration(days: 30));
        endDate = DateTime.now();
        break;
      case 'custom':
        startDate = _startDate;
        endDate = _endDate;
        break;
      case 'all':
      default:
        startDate = null;
        endDate = null;
    }

    final result = await ref.read(getDeliveryHistoryUseCaseProvider).call(
          widget.farmer!.id,
          startDate: startDate,
          endDate: endDate,
        );

    setState(() {
      _isLoading = false;
    });

    switch (result) {
      case Success(:final value):
        setState(() {
          _deliveries = value;
        });
      case Error(:final failure):
        setState(() {
          _errorMessage = failure.message;
        });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = 'custom';
      });
      _loadDeliveries();
    }
  }

  String _formatCurrency(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final parts = <String>[];
    var remaining = formatter;

    while (remaining.length > 3) {
      parts.insert(0, remaining.substring(remaining.length - 3));
      remaining = remaining.substring(0, remaining.length - 3);
    }
    if (remaining.isNotEmpty) {
      parts.insert(0, remaining);
    }

    return 'TZS ${parts.join(',')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  double _calculateTotalLiters() {
    return _deliveries.fold(0, (sum, delivery) => sum + delivery.quantityLiters);
  }

  double _calculateTotalAmount() {
    return _deliveries.fold(0, (sum, delivery) => sum + delivery.totalAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).deliveryHistory),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _deliveries.isEmpty ? null : _exportData,
            tooltip: 'Export',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Period',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedPeriod == 'all',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPeriod = 'all';
                              _startDate = null;
                              _endDate = null;
                            });
                            _loadDeliveries();
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Today'),
                        selected: _selectedPeriod == 'today',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedPeriod = 'today');
                            _loadDeliveries();
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Last 7 Days'),
                        selected: _selectedPeriod == 'week',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedPeriod = 'week');
                            _loadDeliveries();
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Last 30 Days'),
                        selected: _selectedPeriod == 'month',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedPeriod = 'month');
                            _loadDeliveries();
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text(_selectedPeriod == 'custom' && _startDate != null
                            ? 'Custom Range'
                            : 'Custom'),
                        selected: _selectedPeriod == 'custom',
                        onSelected: (selected) {
                          if (selected) {
                            _selectDateRange();
                          }
                        },
                      ),
                    ],
                  ),
                  if (_selectedPeriod == 'custom' &&
                      _startDate != null &&
                      _endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Summary section
          if (!_isLoading && _deliveries.isNotEmpty)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      icon: Icons.receipt,
                      label: 'Deliveries',
                      value: '${_deliveries.length}',
                      color: Colors.blue,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    _buildSummaryItem(
                      icon: Icons.water_drop,
                      label: 'Total Liters',
                      value: _calculateTotalLiters().toStringAsFixed(1),
                      color: Colors.green,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    _buildSummaryItem(
                      icon: Icons.payments,
                      label: 'Total Amount',
                      value: _formatCurrency(_calculateTotalAmount()),
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Deliveries list
          Expanded(
            child: _buildDeliveriesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveriesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading history',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDeliveries,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      );
    }

    if (_deliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No deliveries found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting the date filter',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Group deliveries by date
    final groupedDeliveries = <String, List<MilkDelivery>>{};
    for (final delivery in _deliveries) {
      final dateKey = _formatDate(delivery.deliveryDate);
      groupedDeliveries.putIfAbsent(dateKey, () => []);
      groupedDeliveries[dateKey]!.add(delivery);
    }

    final sortedDates = groupedDeliveries.keys.toList()
      ..sort((a, b) {
        // Sort dates in descending order (newest first)
        final dateA = groupedDeliveries[a]!.first.deliveryDate;
        final dateB = groupedDeliveries[b]!.first.deliveryDate;
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final deliveries = groupedDeliveries[dateKey]!;

        // Calculate daily totals
        final dailyLiters =
            deliveries.fold(0.0, (sum, d) => sum + d.quantityLiters);
        final dailyAmount =
            deliveries.fold(0.0, (sum, d) => sum + d.totalAmount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateKey,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${dailyLiters.toStringAsFixed(1)}L • ${_formatCurrency(dailyAmount)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Deliveries for this date
            ...deliveries.map((delivery) => _DeliveryCard(
                  delivery: delivery,
                  onTap: () => _showDeliveryDetails(delivery),
                )),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  void _showDeliveryDetails(MilkDelivery delivery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Delivery Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow(
                  'Date',
                  _formatDate(delivery.deliveryDate),
                  Icons.calendar_today,
                ),
                _buildDetailRow(
                  'Time',
                  _formatTime(delivery.deliveryDate),
                  Icons.access_time,
                ),
                const Divider(height: 32),
                _buildDetailRow(
                  'Quantity',
                  '${delivery.quantityLiters.toStringAsFixed(1)} Liters',
                  Icons.water_drop,
                ),
                _buildDetailRow(
                  'Quality Grade',
                  delivery.qualityGrade.name.toUpperCase(),
                  Icons.grade,
                ),
                _buildDetailRow(
                  'Price per Liter',
                  _formatCurrency(delivery.pricePerLiter),
                  Icons.attach_money,
                ),
                const Divider(height: 32),
                _buildDetailRow(
                  'Total Amount',
                  _formatCurrency(delivery.totalAmount),
                  Icons.payments,
                  isHighlighted: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isHighlighted ? Colors.green : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                    color: isHighlighted ? Colors.green : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    // TODO: Implement CSV export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon'),
      ),
    );
  }
}

/// Widget to display a delivery card
class _DeliveryCard extends StatelessWidget {
  final MilkDelivery delivery;
  final VoidCallback onTap;

  const _DeliveryCard({
    required this.delivery,
    required this.onTap,
  });

  String _formatCurrency(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final parts = <String>[];
    var remaining = formatter;

    while (remaining.length > 3) {
      parts.insert(0, remaining.substring(remaining.length - 3));
      remaining = remaining.substring(0, remaining.length - 3);
    }
    if (remaining.isNotEmpty) {
      parts.insert(0, remaining);
    }

    return 'TZS ${parts.join(',')}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.water_drop,
            color: Colors.blue.shade700,
          ),
        ),
        title: Text(
          '${delivery.quantityLiters.toStringAsFixed(1)} L',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(_formatTime(delivery.deliveryDate)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatCurrency(delivery.totalAmount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 14,
              ),
            ),
            Text(
              delivery.qualityGrade.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
