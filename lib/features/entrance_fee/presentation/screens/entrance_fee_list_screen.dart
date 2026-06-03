import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livestock/features/entrance_fee/domain/entities/farmer_payment_status.dart';
import 'package:livestock/features/entrance_fee/presentation/providers/entrance_fee_providers.dart';
import 'package:livestock/features/entrance_fee/presentation/widgets/farmer_payment_card.dart';
import 'package:livestock/features/entrance_fee/presentation/widgets/payment_details_dialog.dart';
import 'package:livestock/features/entrance_fee/presentation/widgets/payment_summary_card.dart';

/// Screen displaying list of farmers with entrance fee payment status
class EntranceFeeListScreen extends ConsumerStatefulWidget {
  const EntranceFeeListScreen({super.key});

  @override
  ConsumerState<EntranceFeeListScreen> createState() => _EntranceFeeListScreenState();
}

class _EntranceFeeListScreenState extends ConsumerState<EntranceFeeListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final farmersPaymentStatusAsync = ref.watch(allFarmersPaymentStatusProvider);
    final paymentSummaryAsync = ref.watch(paymentSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrance Fees'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Payment summary card
          paymentSummaryAsync.when(
            data: (summary) => PaymentSummaryCard(summary: summary),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading summary: $error'),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search farmers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Farmers list
          Expanded(
            child: farmersPaymentStatusAsync.when(
              data: (farmers) {
                final filteredFarmers = _searchQuery.isEmpty
                    ? farmers
                    : farmers.where((farmer) {
                        return farmer.farmerName.toLowerCase().contains(_searchQuery) ||
                            farmer.phoneNumber.contains(_searchQuery);
                      }).toList();

                if (filteredFarmers.isEmpty) {
                  return const Center(
                    child: Text('No farmers found'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredFarmers.length,
                  itemBuilder: (context, index) {
                    final status = filteredFarmers[index];
                    return FarmerPaymentCard(
                      status: status,
                      onTap: () => _handleFarmerTap(context, status),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(allFarmersPaymentStatusProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFarmerTap(BuildContext context, FarmerPaymentStatus status) {
    if (status.hasPaid && status.payment != null) {
      // Show payment details dialog
      showDialog(
        context: context,
        builder: (context) => PaymentDetailsDialog(
          payment: status.payment!,
          farmerName: status.farmerName,
        ),
      );
    } else {
      // Navigate to record payment screen
      context.push('/entrance-fee/record', extra: status);
    }
  }
}
