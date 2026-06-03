import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Farmer Dashboard Screen - Self-service interface for farmers
class FarmerDashboard extends ConsumerWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAuthUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: _FarmerProfileAppBarSection(user: user),
        elevation: 0,
        actions: [
          // Notifications
          IconButton(
            icon: const Badge(
              label: Text('2'),
              child: Icon(Icons.notifications),
            ),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate all farmer dashboard providers to refresh data
          ref.invalidate(farmerMonthlySummaryProvider);
          
          // Wait for data to reload
          await ref.read(farmerMonthlySummaryProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Monthly Summary Card
            _MonthlySummaryCard(),
            const SizedBox(height: 16),

            // Financial Overview Cards
            Row(
              children: [
                Expanded(child: _PendingPaymentCard()),
                const SizedBox(width: 12),
                Expanded(child: _ActiveLoanCard()),
              ],
            ),
            const SizedBox(height: 16),

            // Insurance Status Card
            _InsuranceStatusCard(),
            const SizedBox(height: 24),

            // Quick Links Section
            Text(
              AppLocalizations.of(context).quickLinks,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _QuickLinksGrid(),
          ],
        ),
      ),
    );
  }
}

/// Farmer profile section for app bar
class _FarmerProfileAppBarSection extends StatelessWidget {
  final dynamic user;

  const _FarmerProfileAppBarSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final greeting = _getTimeBasedGreeting(context);
    final displayName = user?.displayName ?? 'Farmer';

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
      return 'F';
    }

    final parts = displayName.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

/// Monthly milk summary card
class _MonthlySummaryCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(farmerMonthlySummaryProvider);

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: summaryAsync.when(
          data: (summary) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).thisMonth,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      DateFormat('MMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      icon: Icons.water_drop,
                      label: AppLocalizations.of(context).totalLiters,
                      value: NumberFormat('#,##0.#', 'en_US').format(summary['totalLiters'] ?? 0),
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryItem(
                      icon: Icons.calendar_today,
                      label: AppLocalizations.of(context).deliveries,
                      value: (summary['deliveryCount'] ?? 0).toString(),
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryItem(
                      icon: Icons.payments,
                      label: AppLocalizations.of(context).earnings,
                      value: 'TZS ${NumberFormat('#,##0', 'en_US').format(summary['totalEarnings'] ?? 0)}',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                AppLocalizations.of(context).errorLoadingSummary,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pending payment card
class _PendingPaymentCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentAsync = ref.watch(farmerPendingPaymentProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: paymentAsync.when(
          data: (amount) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.green.shade600,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).pendingPayment,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'TZS ${NumberFormat('#,##0', 'en_US').format(amount)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.grey[400],
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).pendingPayment,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'TZS 0',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Active loan card
class _ActiveLoanCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAsync = ref.watch(farmerActiveLoanBalanceProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: loanAsync.when(
          data: (balance) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.money,
                color: balance > 0 ? Colors.orange.shade600 : Colors.grey[400],
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).loanBalance,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'TZS ${NumberFormat('#,##0', 'en_US').format(balance)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: balance > 0 ? Colors.orange.shade700 : Colors.grey[700],
                ),
              ),
            ],
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.money,
                color: Colors.grey[400],
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).loanBalance,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'TZS 0',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Insurance status card
class _InsuranceStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insuranceAsync = ref.watch(farmerInsuranceStatusProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: insuranceAsync.when(
          data: (status) {
            final isActive = status['isActive'] ?? false;
            final coveredCattle = status['coveredCattle'] ?? 0;
            
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue.shade50 : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield,
                    color: isActive ? Colors.blue.shade600 : Colors.grey[400],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).insuranceStatus,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isActive 
                            ? AppLocalizations.of(context).active 
                            : AppLocalizations.of(context).inactive,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.blue.shade700 : Colors.grey[700],
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$coveredCattle ${AppLocalizations.of(context).cattleCovered}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield,
                  color: Colors.grey[400],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).insuranceStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).inactive,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick links grid
class _QuickLinksGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _QuickLinkCard(
          icon: Icons.water_drop,
          label: AppLocalizations.of(context).milkHistory,
          color: Colors.blue,
          onTap: () {
            Navigator.pushNamed(context, '/farmer/milk-history');
          },
        ),
        _QuickLinkCard(
          icon: Icons.pets,
          label: AppLocalizations.of(context).myCattle,
          color: Colors.green,
          onTap: () {
            Navigator.pushNamed(context, '/farmer/cattle');
          },
        ),
        _QuickLinkCard(
          icon: Icons.money,
          label: AppLocalizations.of(context).loanDetails,
          color: Colors.orange,
          onTap: () {
            Navigator.pushNamed(context, '/farmer/loans');
          },
        ),
        _QuickLinkCard(
          icon: Icons.shield,
          label: AppLocalizations.of(context).insurance,
          color: Colors.purple,
          onTap: () {
            Navigator.pushNamed(context, '/farmer/insurance');
          },
        ),
      ],
    );
  }
}

/// Quick link card widget
class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Summary item widget
class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
