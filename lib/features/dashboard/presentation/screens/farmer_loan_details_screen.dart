import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/loans/domain/entities/loan.dart';
import 'package:livestock/features/loans/domain/entities/loan_repayment.dart';
import 'package:livestock/l10n/app_localizations.dart';

/// Farmer Loan Details Screen - Shows loan information and repayment history
class FarmerLoanDetailsScreen extends ConsumerWidget {
  const FarmerLoanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAuthUserProvider);
    final loansAsync = ref.watch(farmerLoansProvider(user?.uid ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).loanDetails),
        elevation: 0,
      ),
      body: loansAsync.when(
        data: (loans) {
          if (loans.isEmpty) {
            return _EmptyState(
              icon: Icons.account_balance_wallet,
              message: AppLocalizations.of(context).noActiveLoans,
              subtitle: AppLocalizations.of(context).applyForLoanToGetStarted,
            );
          }

          // Separate active and completed loans
          final activeLoans = loans.where((loan) => 
            loan.status == LoanStatus.active || 
            loan.status == LoanStatus.disbursed
          ).toList();
          
          final completedLoans = loans.where((loan) => 
            loan.status == LoanStatus.completed
          ).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (activeLoans.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context).activeLoans,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...activeLoans.map((loan) => _LoanCard(loan: loan)),
                const SizedBox(height: 24),
              ],
              
              if (completedLoans.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context).completedLoans,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...completedLoans.map((loan) => _LoanCard(loan: loan)),
              ],
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _EmptyState(
          icon: Icons.error_outline,
          message: AppLocalizations.of(context).errorLoadingLoans,
        ),
      ),
    );
  }
}

/// Loan card widget
class _LoanCard extends StatelessWidget {
  final Loan loan;

  const _LoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final isActive = loan.status == LoanStatus.active || loan.status == LoanStatus.disbursed;
    final progress = loan.principalAmount > 0 
        ? (loan.principalAmount - loan.outstandingBalance) / loan.principalAmount 
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _LoanDetailView(loan: loan),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.orange.shade50 : Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: isActive ? Colors.orange.shade600 : Colors.green.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).inputLoan,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${loan.termMonths} ${AppLocalizations.of(context).months} • ${loan.interestRate.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(loan.status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusLabel(loan.status, context),
                      style: TextStyle(
                        fontSize: 11,
                        color: _getStatusColor(loan.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Amount details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).loanAmount,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TZS ${NumberFormat('#,##0', 'en_US').format(loan.principalAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppLocalizations.of(context).outstanding,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TZS ${NumberFormat('#,##0', 'en_US').format(loan.outstandingBalance)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.orange.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              if (isActive) ...[
                const SizedBox(height: 16),
                
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context).repaymentProgress,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Next payment due
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${AppLocalizations.of(context).nextPaymentDue}: ${DateFormat('MMM d, yyyy').format(loan.nextPaymentDue)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.active:
      case LoanStatus.disbursed:
        return Colors.orange;
      case LoanStatus.completed:
        return Colors.green;
      case LoanStatus.pending:
      case LoanStatus.approved:
        return Colors.blue;
      case LoanStatus.defaulted:
      case LoanStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusLabel(LoanStatus status, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case LoanStatus.active:
        return l10n.active;
      case LoanStatus.disbursed:
        return l10n.disbursed;
      case LoanStatus.completed:
        return l10n.completed;
      case LoanStatus.pending:
        return l10n.pending;
      case LoanStatus.approved:
        return l10n.approved;
      case LoanStatus.defaulted:
        return l10n.defaulted;
      case LoanStatus.rejected:
        return l10n.rejected;
    }
  }
}

/// Loan detail view (full screen)
class _LoanDetailView extends ConsumerWidget {
  final Loan loan;

  const _LoanDetailView({required this.loan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repaymentsAsync = ref.watch(loanRepaymentsProvider(loan.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).loanDetails),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Loan summary card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).loanSummary,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: AppLocalizations.of(context).loanAmount,
                    value: 'TZS ${NumberFormat('#,##0', 'en_US').format(loan.principalAmount)}',
                  ),
                  _DetailRow(
                    label: AppLocalizations.of(context).interestRate,
                    value: '${loan.interestRate.toStringAsFixed(1)}% ${_getInterestTypeLabel(loan.interestType, context)}',
                  ),
                  _DetailRow(
                    label: AppLocalizations.of(context).loanTerm,
                    value: '${loan.termMonths} ${AppLocalizations.of(context).months}',
                  ),
                  _DetailRow(
                    label: AppLocalizations.of(context).disbursementDate,
                    value: DateFormat('MMM d, yyyy').format(loan.disbursementDate),
                  ),
                  _DetailRow(
                    label: AppLocalizations.of(context).outstanding,
                    value: 'TZS ${NumberFormat('#,##0', 'en_US').format(loan.outstandingBalance)}',
                    valueColor: Colors.orange.shade700,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Payment schedule section
          Text(
            AppLocalizations.of(context).paymentHistory,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          repaymentsAsync.when(
            data: (repayments) {
              if (repayments.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context).noPaymentsYet,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: repayments.map((repayment) {
                  return _RepaymentCard(repayment: repayment);
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).errorLoadingPayments,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInterestTypeLabel(InterestType type, BuildContext context) {
    switch (type) {
      case InterestType.flat:
        return AppLocalizations.of(context).flat;
      case InterestType.reducingBalance:
        return AppLocalizations.of(context).reducingBalance;
    }
  }
}

/// Detail row widget
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

/// Repayment card widget
class _RepaymentCard extends StatelessWidget {
  final LoanRepayment repayment;

  const _RepaymentCard({required this.repayment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getPaymentMethodIcon(repayment.paymentMethod),
                color: Colors.green.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(repayment.paymentDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPaymentMethodLabel(repayment.paymentMethod, context),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TZS ${NumberFormat('#,##0', 'en_US').format(repayment.amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context).principal}: ${NumberFormat('#,##0', 'en_US').format(repayment.principalPaid)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.milkDeduction:
        return Icons.water_drop;
      case PaymentMethod.mobileMoney:
        return Icons.phone_android;
    }
  }

  String _getPaymentMethodLabel(PaymentMethod method, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (method) {
      case PaymentMethod.milkDeduction:
        return l10n.milkDeduction;
      case PaymentMethod.mobileMoney:
        return l10n.mobileMoney;
    }
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.subtitle,
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Provider for farmer's loans
final farmerLoansProvider = FutureProvider.family<List<Loan>, String>(
  (ref, farmerId) async {
    if (farmerId.isEmpty) {
      return [];
    }

    // TODO: Implement actual loan fetching from repository
    // For now, returning empty list as placeholder
    return [];
  },
);

/// Provider for loan repayments
final loanRepaymentsProvider = FutureProvider.family<List<LoanRepayment>, String>(
  (ref, loanId) async {
    if (loanId.isEmpty) {
      return [];
    }

    // TODO: Implement actual repayment fetching from repository
    // For now, returning empty list as placeholder
    return [];
  },
);
