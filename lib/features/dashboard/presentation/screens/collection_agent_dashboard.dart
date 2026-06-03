import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:livestock/features/dashboard/presentation/widgets/collection_trend_chart.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_providers.dart';
import 'package:livestock/features/milk_collection/domain/entities/milk_delivery.dart';
import 'package:livestock/features/milk_collection/presentation/screens/all_deliveries_screen.dart';
import 'package:livestock/l10n/app_localizations.dart';
import 'package:livestock/features/inventory/presentation/widgets/dashboard_low_stock_card.dart';
import 'package:livestock/features/dashboard/presentation/widgets/enhanced_summary_card.dart';
import 'package:livestock/features/dashboard/presentation/widgets/top_farmers_card.dart';

/// Collection Agent Dashboard Screen
class CollectionAgentDashboard extends ConsumerWidget {
  const CollectionAgentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAuthUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: _UserProfileAppBarSection(user: user),
        elevation: 0,
        actions: [
          // Notifications
          IconButton(
            icon: const Badge(
              label: Text('3'),
              child:HugeIcon(icon:HugeIcons.strokeRoundedNotification01)
            ),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate all dashboard providers to refresh data
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(collectionTrendProvider);
          ref.invalidate(recentDeliveriesProvider);
          ref.invalidate(todaysSalesSummaryProvider);
          ref.invalidate(inventoryStatusProvider);
          ref.invalidate(topFarmersThisMonthProvider);
          
          // Wait for data to reload
          await Future.wait([
            ref.read(dashboardSummaryProvider.future),
            ref.read(collectionTrendProvider.future),
            ref.read(recentDeliveriesProvider.future),
            ref.read(todaysSalesSummaryProvider.future),
            ref.read(inventoryStatusProvider.future),
            ref.read(topFarmersThisMonthProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Enhanced Summary Card with Collection, Inventory & Sales
            const EnhancedSummaryCard(),
            const SizedBox(height: 16),

            // Low Stock Alert Card
            const DashboardLowStockCard(),
            const SizedBox(height: 24),

            // Collection Trends Section
            _CollectionTrendSection(),
            const SizedBox(height: 24),

            // Recent Deliveries
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).recentDeliveries,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AllDeliveriesScreen(),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context).viewAll),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RecentDeliveriesList(),
            const SizedBox(height: 24),

            // Top Farmers This Month
            const TopFarmersCard(),
          ],
        ),
      ),
    );
  }
}

/// User profile section for app bar
class _UserProfileAppBarSection extends StatelessWidget {
  final dynamic user;

  const _UserProfileAppBarSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final greeting = _getTimeBasedGreeting(context);
    final displayName = user?.displayName ?? 'Collection Agent';

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: user?.photoUrl != null
              ? NetworkImage(user!.photoUrl!)
              : null,
          child: user?.photoUrl == null
              ? Text(
                  _getUserInitials(displayName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getTimeBasedGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return l10n.goodMorning;
    } else if (hour >= 12 && hour < 17) {
      return l10n.goodAfternoon;
    } else {
      return l10n.goodEvening;
    }
  }

  String _getUserInitials(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return 'CA';
    }

    final parts = displayName.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

/// Collection trend section with chart
class _CollectionTrendSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(collectionTrendProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: trendAsync.when(
          data: (trendData) => CollectionTrendChart(
            data: trendData.dataPoints,
            period: trendData.period,
            onPeriodChanged: (newPeriod) {
              ref.read(selectedTrendPeriodProvider.notifier).setPeriod(newPeriod);
            },
          ),
          loading: () => const SizedBox(
            height: 250,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => SizedBox(
            height: 250,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).errorLoadingTrend,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ref.invalidate(collectionTrendProvider);
                    },
                    child: Text(AppLocalizations.of(context).retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Recent deliveries list widget
class _RecentDeliveriesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesAsync = ref.watch(recentDeliveriesProvider);

    return deliveriesAsync.when(
      data: (deliveries) {
        if (deliveries.isEmpty) {
          return _EmptyState(
            icon: Icons.water_drop_outlined,
            message: AppLocalizations.of(context).noDeliveriesRecorded,
          );
        }

        return Column(
          children: deliveries.map((delivery) {
            return _DeliveryListItem(delivery: delivery);
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => _EmptyState(
        icon: Icons.error_outline,
        message: AppLocalizations.of(context).errorLoadingDeliveries,
      ),
    );
  }
}

/// Individual delivery list item
class _DeliveryListItem extends ConsumerWidget {
  final MilkDelivery delivery;

  const _DeliveryListItem({required this.delivery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch farmer name
    final farmerAsync = ref.watch(farmerByIdProvider(delivery.farmerId));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getQualityColor(delivery.qualityGrade).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.water_drop,
            color: _getQualityColor(delivery.qualityGrade),
          ),
        ),
        title: farmerAsync.when(
          data: (Farmer? farmer) => Text(
            farmer?.name ?? AppLocalizations.of(context).unknownFarmer,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          loading: () => Text(AppLocalizations.of(context).loading),
          error: (_, __) => Text(AppLocalizations.of(context).unknownFarmer),
        ),
        subtitle: Text(_getRelativeTime(delivery.createdAt, context)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${delivery.quantityLiters.toStringAsFixed(1)}L',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getQualityColor(delivery.qualityGrade).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getQualityLabel(delivery.qualityGrade),
                style: TextStyle(
                  fontSize: 10,
                  color: _getQualityColor(delivery.qualityGrade),
                  fontWeight: FontWeight.bold,
                ),
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

  String _getRelativeTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    try {
      final l10n = AppLocalizations.of(context);
      
      if (difference.inMinutes < 1) {
        return l10n.justNow;
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} ${l10n.minAgo}';
      } else if (difference.inHours < 24) {
        return l10n.hoursAgo(difference.inHours);
      } else {
        return DateFormat('MMM d, h:mm a').format(dateTime);
      }
    } catch (e) {
      // Fallback to English if localization fails
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return DateFormat('MMM d, h:mm a').format(dateTime);
      }
    }
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
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
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
