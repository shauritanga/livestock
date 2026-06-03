import 'package:flutter/material.dart';
import 'package:livestock/features/entrance_fee/domain/entities/farmer_payment_status.dart';

/// Widget displaying a farmer with their payment status
class FarmerPaymentCard extends StatelessWidget {
  final FarmerPaymentStatus status;
  final VoidCallback onTap;

  const FarmerPaymentCard({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: status.hasPaid ? Colors.green : Colors.orange,
          child: Icon(
            status.hasPaid ? Icons.check : Icons.pending,
            color: Colors.white,
          ),
        ),
        title: Text(
          status.farmerName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status.phoneNumber),
            if (status.hasPaid && status.payment != null) ...[
              const SizedBox(height: 4),
              Text(
                'Paid: ${status.payment!.getFormattedAmount()}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(
          status.hasPaid ? Icons.info_outline : Icons.add_circle_outline,
          color: status.hasPaid ? Colors.blue : Colors.green,
        ),
        onTap: onTap,
      ),
    );
  }
}
