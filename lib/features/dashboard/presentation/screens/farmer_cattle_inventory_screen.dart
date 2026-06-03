import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/cattle_tracking/presentation/providers/cattle_providers.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Farmer Cattle Inventory Screen - Shows all cattle owned by the farmer
class FarmerCattleInventoryScreen extends ConsumerWidget {
  const FarmerCattleInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAuthUserProvider);
    final cattleAsync = ref.watch(farmerCattleListProvider(user?.uid ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).myCattle),
        elevation: 0,
      ),
      body: cattleAsync.when(
        data: (cattle) {
          if (cattle.isEmpty) {
            return _EmptyState(
              icon: Icons.pets,
              message: AppLocalizations.of(context).noCattleRegistered,
            );
          }

          // Calculate statistics
          final stats = _calculateCattleStats(cattle);

          return Column(
            children: [
              // Statistics cards
              _StatisticsSection(stats: stats),
              
              // Cattle list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cattle.length,
                  itemBuilder: (context, index) {
                    return _CattleCard(cattle: cattle[index]);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _EmptyState(
          icon: Icons.error_outline,
          message: AppLocalizations.of(context).errorLoadingCattle,
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateCattleStats(List<Cattle> cattle) {
    int lactating = 0;
    int dry = 0;
    int pregnant = 0;
    int calves = 0;
    double totalProduction = 0.0;

    for (final animal in cattle) {
      switch (animal.lactationStatus) {
        case LactationStatus.lactating:
          lactating++;
          totalProduction += animal.averageDailyProduction ?? 0.0;
          break;
        case LactationStatus.dry:
          dry++;
          break;
        case LactationStatus.pregnant:
          pregnant++;
          break;
        case LactationStatus.calf:
          calves++;
          break;
      }
    }

    return {
      'total': cattle.length,
      'lactating': lactating,
      'dry': dry,
      'pregnant': pregnant,
      'calves': calves,
      'avgProduction': lactating > 0 ? totalProduction / lactating : 0.0,
    };
  }
}

/// Statistics section widget
class _StatisticsSection extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatisticsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Total cattle card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.pets,
                    label: AppLocalizations.of(context).totalCattle,
                    value: stats['total'].toString(),
                    color: Colors.blue,
                  ),
                  _StatItem(
                    icon: Icons.water_drop,
                    label: AppLocalizations.of(context).avgProduction,
                    value: '${stats['avgProduction'].toStringAsFixed(1)}L',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Status breakdown
          Row(
            children: [
              Expanded(
                child: _StatusCard(
                  label: AppLocalizations.of(context).lactating,
                  count: stats['lactating'],
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusCard(
                  label: AppLocalizations.of(context).dry,
                  count: stats['dry'],
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusCard(
                  label: AppLocalizations.of(context).pregnant,
                  count: stats['pregnant'],
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusCard(
                  label: AppLocalizations.of(context).calves,
                  count: stats['calves'],
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 36),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Status card widget
class _StatusCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Cattle card widget
class _CattleCard extends StatelessWidget {
  final Cattle cattle;

  const _CattleCard({required this.cattle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to cattle details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Cattle image or placeholder
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _getLactationColor(cattle.lactationStatus).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: cattle.muzzleImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          cattle.muzzleImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.pets,
                              size: 40,
                              color: _getLactationColor(cattle.lactationStatus),
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.pets,
                        size: 40,
                        color: _getLactationColor(cattle.lactationStatus),
                      ),
              ),
              const SizedBox(width: 16),
              
              // Cattle details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cattle.breed,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getLactationColor(cattle.lactationStatus).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getLactationLabel(cattle.lactationStatus, context),
                            style: TextStyle(
                              fontSize: 11,
                              color: _getLactationColor(cattle.lactationStatus),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          cattle.gender == CattleGender.female
                              ? Icons.female
                              : Icons.male,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_getAgeInYears(cattle.ageMonths)} • ${cattle.healthStatus}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (cattle.lactationStatus == LactationStatus.lactating) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 14,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${AppLocalizations.of(context).avgDaily}: ${cattle.averageDailyProduction.toStringAsFixed(1)}L',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (cattle.lastProductionDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${AppLocalizations.of(context).lastDelivery}: ${_getRelativeTime(cattle.lastProductionDate!, context)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Chevron
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLactationColor(LactationStatus status) {
    switch (status) {
      case LactationStatus.lactating:
        return Colors.green;
      case LactationStatus.dry:
        return Colors.orange;
      case LactationStatus.pregnant:
        return Colors.purple;
      case LactationStatus.calf:
        return Colors.blue;
    }
  }

  String _getLactationLabel(LactationStatus status, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case LactationStatus.lactating:
        return l10n.lactating;
      case LactationStatus.dry:
        return l10n.dry;
      case LactationStatus.pregnant:
        return l10n.pregnant;
      case LactationStatus.calf:
        return l10n.calf;
    }
  }

  String _getAgeInYears(int ageInMonths) {
    if (ageInMonths < 12) {
      return '$ageInMonths months';
    }
    final years = ageInMonths ~/ 12;
    final months = ageInMonths % 12;
    if (months == 0) {
      return '$years ${years == 1 ? 'year' : 'years'}';
    }
    return '$years ${years == 1 ? 'year' : 'years'} $months ${months == 1 ? 'month' : 'months'}';
  }

  String _getRelativeTime(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
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

/// Provider for farmer's cattle list
final farmerCattleListProvider = FutureProvider.family<List<Cattle>, String>(
  (ref, farmerId) async {
    if (farmerId.isEmpty) {
      return [];
    }

    final repository = ref.watch(cattleRepositoryProvider);
    final result = await repository.getCattleByFarmer(farmerId);

    return result.fold(
      onError: (failure) => [],
      onSuccess: (cattle) => cattle,
    );
  },
);
