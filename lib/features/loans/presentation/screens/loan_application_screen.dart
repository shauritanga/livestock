import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/result.dart';
import '../../../insurance/presentation/providers/insurance_providers.dart';
import '../providers/loan_providers.dart';

/// Loan application screen for farmers to apply for input loans
/// 
/// Verifies insurance eligibility before showing the form
/// Displays loan options with interest rates and repayment schedules
class LoanApplicationScreen extends ConsumerStatefulWidget {
  final String farmerId;
  final String cooperativeId;

  const LoanApplicationScreen({
    super.key,
    required this.farmerId,
    required this.cooperativeId,
  });

  @override
  ConsumerState<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends ConsumerState<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  double _loanAmount = 50000;
  int _termMonths = 6;
  double _interestRate = 2.0; // 2% monthly
  
  bool _isLoading = false;
  bool _insuranceVerified = false;
  bool _checkingInsurance = true;

  @override
  void initState() {
    super.initState();
    _verifyInsurance();
  }

  Future<void> _verifyInsurance() async {
    setState(() => _checkingInsurance = true);
    
    // Check if farmer has active insurance
    final getFarmerPolicies = ref.read(getFarmerPoliciesUseCaseProvider(widget.cooperativeId));
    final result = await getFarmerPolicies(widget.farmerId);

    setState(() {
      _checkingInsurance = false;
      _insuranceVerified = result.isSuccess && (result.valueOrNull?.isNotEmpty ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.applyForLoan),
        elevation: 0,
      ),
      body: _checkingInsurance
          ? const Center(child: CircularProgressIndicator())
          : !_insuranceVerified
              ? _buildInsuranceRequiredView(context, l10n)
              : _buildLoanApplicationForm(context, l10n),
    );
  }

  Widget _buildInsuranceRequiredView(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 100,
              color: Colors.orange[700],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.insuranceRequired,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.allProductiveCattleMustBeInsured,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.pop();
                context.push('/insurance');
              },
              icon: const Icon(Icons.security),
              label: Text(l10n.getInsuranceNow),
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

  Widget _buildLoanApplicationForm(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.loanDetails,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLoanAmountSlider(l10n),
                    const SizedBox(height: 24),
                    _buildTermSelector(l10n),
                    const SizedBox(height: 24),
                    _buildInterestRateSelector(l10n),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildRepaymentSchedule(l10n),
            const SizedBox(height: 24),
            _buildApplicationStatus(l10n),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.submitApplication,
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanAmountSlider(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.loanAmount,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'KES ${_loanAmount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Slider(
          value: _loanAmount,
          min: 10000,
          max: 200000,
          divisions: 19,
          label: 'KES ${_loanAmount.toStringAsFixed(0)}',
          onChanged: (value) {
            setState(() => _loanAmount = value);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('KES 10,000', style: TextStyle(color: Colors.grey[600])),
            Text('KES 200,000', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildTermSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.loanTerm,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 3, label: Text('3 months')),
            ButtonSegment(value: 6, label: Text('6 months')),
            ButtonSegment(value: 12, label: Text('12 months')),
          ],
          selected: {_termMonths},
          onSelectionChanged: (Set<int> newSelection) {
            setState(() {
              _termMonths = newSelection.first;
              // Adjust interest rate based on term
              _interestRate = _termMonths <= 6 ? 2.0 : 1.8;
            });
          },
        ),
      ],
    );
  }

  Widget _buildInterestRateSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.interestRate,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${_interestRate.toStringAsFixed(1)}% ${l10n.perMonth}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(_interestRate * 12).toStringAsFixed(1)}% ${l10n.annually}',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRepaymentSchedule(AppLocalizations l10n) {
    final totalInterest = _loanAmount * (_interestRate / 100) * _termMonths;
    final totalRepayment = _loanAmount + totalInterest;
    final monthlyPayment = totalRepayment / _termMonths;

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
            _buildRepaymentRow(
              l10n.principal,
              'KES ${_loanAmount.toStringAsFixed(2)}',
            ),
            _buildRepaymentRow(
              l10n.totalInterest,
              'KES ${totalInterest.toStringAsFixed(2)}',
            ),
            const Divider(),
            _buildRepaymentRow(
              l10n.totalRepayment,
              'KES ${totalRepayment.toStringAsFixed(2)}',
              bold: true,
            ),
            const SizedBox(height: 8),
            _buildRepaymentRow(
              l10n.monthlyPayment,
              'KES ${monthlyPayment.toStringAsFixed(2)}',
              color: Colors.green,
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

  Widget _buildRepaymentRow(String label, String value, {bool bold = false, Color? color}) {
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

  Widget _buildApplicationStatus(AppLocalizations l10n) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  l10n.eligibilityStatus,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusItem(Icons.security, l10n.insuranceVerified),
            _buildStatusItem(Icons.account_balance, l10n.loanEligible),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final applyForLoan = ref.read(applyForLoanProvider);
    final result = await applyForLoan(
      farmerId: widget.farmerId,
      cooperativeId: widget.cooperativeId,
      principalAmount: _loanAmount,
      interestRate: _interestRate,
      termMonths: _termMonths,
      mfiPartnerId: 'default_mfi', // TODO: Get from cooperative config
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    result.fold(
      onSuccess: (loan) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).applicationSubmitted),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      },
      onError: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}
