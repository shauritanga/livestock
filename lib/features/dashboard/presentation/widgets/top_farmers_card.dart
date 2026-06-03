import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/dashboard/presentation/providers/dashboard_providers.dart';

/// Top Farmers This Month Card
class TopFarmersCard extends ConsumerWidget {
  const TopFarmersCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topFarmersAsync = ref.watch(topFarmersThisMonthProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Top Farmers This Month',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            topFarmersAsync.when(
              data: (farmers) {
                if (farmers.isEmpty) {
                  return _EmptyState();
                }
                
                return Column(
                  children: farmers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final farmer = entry.value;
                    return _FarmerRankItem(
                      rank: index + 1,
                      farmerName: farmer['farmerName'] as String,
                      totalLiters: farmer['totalLiters'] as double,
                      deliveryCount: farmer['deliveryCount'] as int,
                      totalAmount: farmer['totalAmount'] as double,
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => _EmptyState(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual farmer rank item
class _FarmerRankItem extends StatelessWidget {
  final int rank;
  final String farmerName;
  final double totalLiters;
  final int deliveryCount;
  final double totalAmount;

  const _FarmerRankItem({
    required this.rank,
    required this.farmerName,
    required this.totalLiters,
    required this.deliveryCount,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getRankColor(rank).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getRankColor(rank).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(
                      _getRankIcon(rank),
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
                      '$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Farmer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  farmerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 14,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${NumberFormat('#,##0.#', 'en_US').format(totalLiters)}L',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$deliveryCount ${deliveryCount == 1 ? 'delivery' : 'deliveries'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TZS ${NumberFormat('#,##0', 'en_US').format(totalAmount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'earned',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade600; // Gold
      case 2:
        return Colors.grey.shade500; // Silver
      case 3:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.military_tech; // Medal
      case 3:
        return Icons.workspace_premium; // Badge
      default:
        return Icons.star;
    }
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            'No deliveries this month yet',
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
