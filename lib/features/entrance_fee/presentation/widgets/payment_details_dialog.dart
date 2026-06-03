import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/entrance_fee/domain/entities/entrance_fee.dart';

/// Dialog displaying entrance fee payment details
class PaymentDetailsDialog extends StatelessWidget {
  final EntranceFee payment;
  final String farmerName;

  const PaymentDetailsDialog({
    super.key,
    required this.payment,
    required this.farmerName,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return AlertDialog(
      title: const Text('Payment Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Farmer', farmerName),
          const SizedBox(height: 12),
          _buildDetailRow('Amount', payment.getFormattedAmount()),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Payment Date',
            dateFormat.format(payment.paymentDate),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Recorded At',
            dateFormat.format(payment.recordedAt),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
