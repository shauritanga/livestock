import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_repayment.dart';
import '../providers/loan_providers.dart';

/// Loan details screen showing loan information and repayment history
/// 
/// Displays:
/// - Loan amount and balance
/// - Payment schedule
/// - Payment history
/// - Next payment due date
class LoanDetailsScreen extends ConsumerWidget {
  final String loanId;
  final String farmerId;
  final String cooperativeId;

  const LoanDetailsScreen({
    super.key,
    required this.loanId,
    required this.farmerId,
    required this.cooperativeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loanDetails),
        elevation: 0,
      ),
      body: FutureBuilder<Loan?>(
        future: _loadLoanDetails(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading loan details',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final loan = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLoanSummaryCard(context, l10n, loan),
                const SizedBox(height: 16),
                _buildRepaymentScheduleCard(context, l10n, loan),
                const SizedBox(height: 16),
                _buildPaymentHistoryCard(context, l10n, ref),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Loan?> _loadLoanDetails(WidgetRef ref) async {
    final getLoanDetails = ref.read(getLoanDetailsProvider);
    final result = await getLoanDetails(loanId);
    return result.valueOrNull;
  }

  Widget _buildLoanSummaryCard(BuildContext context, AppLocalizations l10n, Loan loan) {
    final progress = 1 - (loan.outstandingBalance / loan.principalAmount);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.loanAmount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(loan.status),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'KES ${loan.principalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
              l10n.outstandingBalance,
              'KES ${loan.outstandingBalance.toStringAsFixed(2)}',
              bold: true,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% paid',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const Divider(height: 32),
            _buildInfoRow(
              l10n.interestRate,
              '${loan.interestRate.toStringAsFixed(1)}% ${l10n.perMonth}',
            ),
            _buildInfoRow(
              l10n.loanTerm,
              '${loan.termMonths} months',
            ),
            _buildInfoRow(
              l10n.nextPaymentDue,
              DateFormat('MMM dd, yyyy').format(loan.nextPaymentDue),
            ),
            _buildInfoRow(
              'Lending Model',
              loan.lendingModel == LendingModel.direct ? 'Direct' : 'Cooperative',
            ),
          ],
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

  Widget _buildRepaymentScheduleCard(BuildContext context, AppLocalizations l10n, Loan loan) {
    final totalInterest = loan.principalAmount * (loan.interestRate / 100) * loan.termMonths;
    final totalRepayment = loan.principalAmount + totalInterest;
    final monthlyPayment = totalRepayment / loan.termMonths;
    final paidAmount = loan.principalAmount - loan.outstandingBalance;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.repaymentSchedule,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(l10n.principal, 'KES ${loan.principalAmount.toStringAsFixed(2)}'),
            _buildInfoRow(l10n.totalInterest, 'KES ${totalInterest.toStringAsFixed(2)}'),
            const Divider(),
            _buildInfoRow(
              l10n.totalRepayment,
              'KES ${totalRepayment.toStringAsFixed(2)}',
              bold: true,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              l10n.monthlyPayment,
              'KES ${monthlyPayment.toStringAsFixed(2)}',
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              l10n.totalPaid,
              'KES ${paidAmount.toStringAsFixed(2)}',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.repaymentDeductedFromMilkPayments,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryCard(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.paymentHistory,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<LoanRepayment>>(
              future: _loadRepaymentHistory(ref),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        l10n.noPaymentsRecorded,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                final repayments = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: repayments.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final repayment = repayments[index];
                    return _buildRepaymentItem(l10n, repayment);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<LoanRepayment>> _loadRepaymentHistory(WidgetRef ref) async {
    final getLoanRepayments = ref.read(getLoanRepaymentsProvider);
    final result = await getLoanRepayments(loanId);
    return result.valueOrNull ?? [];
  }

  Widget _buildRepaymentItem(AppLocalizations l10n, LoanRepayment repayment) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          repayment.paymentMethod == PaymentMethod.milkDeduction
              ? Icons.water_drop
              : Icons.phone_android,
          color: Colors.green[700],
        ),
      ),
      title: Text(
        'KES ${repayment.amount.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('MMM dd, yyyy').format(repayment.paymentDate)),
          Text(
            repayment.paymentMethod == PaymentMethod.milkDeduction
                ? l10n.milkDeduction
                : l10n.mobileMoney,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Principal: ${repayment.principalPaid.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'Interest: ${repayment.interestPaid.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
