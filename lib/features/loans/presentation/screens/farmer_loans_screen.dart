import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/loan.dart';
import '../providers/loan_providers.dart';

/// Screen showing all loans for a farmer
/// 
/// Displays loan list with status, amounts, and navigation to details
class FarmerLoansScreen extends ConsumerWidget {
  final String farmerId;
  final String cooperativeId;

  const FarmerLoansScreen({
    super.key,
    required this.farmerId,
    required this.cooperativeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loans),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push(
                '/loan-application',
                extra: {
                  'farmerId': farmerId,
                  'cooperativeId': cooperativeId,
                },
              );
            },
            tooltip: l10n.applyForLoan,
          ),
        ],
      ),
      body: FutureBuilder<List<Loan>>(
        future: _loadFarmerLoans(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading loans',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Trigger rebuild
                      (context as Element).markNeedsBuild();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final loans = snapshot.data ?? [];

          if (loans.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          return RefreshIndicator(
            onRefresh: () async {
              (context as Element).markNeedsBuild();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: loans.length,
              itemBuilder: (context, index) {
                final loan = loans[index];
                return _buildLoanCard(context, l10n, loan);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(
            '/loan-application',
            extra: {
              'farmerId': farmerId,
              'cooperativeId': cooperativeId,
            },
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.applyForLoan),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<List<Loan>> _loadFarmerLoans(WidgetRef ref) async {
    final getFarmerLoans = ref.read(getFarmerLoansProvider);
    final result = await getFarmerLoans(farmerId);
    return result.valueOrNull ?? [];
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No Loans Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Apply for your first loan to access financial services',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.push(
                  '/loan-application',
                  extra: {
                    'farmerId': farmerId,
                    'cooperativeId': cooperativeId,
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.applyForLoan),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(BuildContext context, AppLocalizations l10n, Loan loan) {
    final progress = 1 - (loan.outstandingBalance / loan.principalAmount);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.push(
            '/loan-details',
            extra: {
              'loanId': loan.id,
              'farmerId': farmerId,
              'cooperativeId': cooperativeId,
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'KES ${loan.principalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(loan.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Applied: ${DateFormat('MMM dd, yyyy').format(loan.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${loan.termMonths} months term',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.percent, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${loan.interestRate.toStringAsFixed(1)}% ${l10n.perMonth}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (loan.status == LoanStatus.active || loan.status == LoanStatus.disbursed) ...[
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.outstandingBalance,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'KES ${loan.outstandingBalance.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% paid',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, size: 14, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n.nextPaymentDue}: ${DateFormat('MMM dd').format(loan.nextPaymentDue)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (loan.status == LoanStatus.pending) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_empty, size: 14, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Application under review',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (loan.status == LoanStatus.rejected && loan.rejectionReason != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cancel, size: 14, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loan.rejectionReason!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(LoanStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case LoanStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case LoanStatus.approved:
        color = Colors.blue;
        label = 'Approved';
        break;
      case LoanStatus.disbursed:
        color = Colors.purple;
        label = 'Disbursed';
        break;
      case LoanStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case LoanStatus.completed:
        color = Colors.teal;
        label = 'Completed';
        break;
      case LoanStatus.defaulted:
        color = Colors.red;
        label = 'Defaulted';
        break;
      case LoanStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
