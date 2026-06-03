import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/presentation/providers/claim_history_provider.dart';

/// Claim history screen for viewing all insurance claims
///
/// This screen displays:
/// - List of all claims for a farmer
/// - Claim status and details
/// - Claim details modal
///
/// Requirements: 6.1, 6.2, 6.7
class ClaimHistoryScreen extends ConsumerStatefulWidget {
  final String farmerId;

  const ClaimHistoryScreen({
    super.key,
    required this.farmerId,
  });

  @override
  ConsumerState<ClaimHistoryScreen> createState() =>
      _ClaimHistoryScreenState();
}

class _ClaimHistoryScreenState extends ConsumerState<ClaimHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClaims();
    });
  }

  void _loadClaims() {
    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    ref.read(claimHistoryProvider.notifier).loadClaims(
          widget.farmerId,
          cooperativeId: user.cooperativeId!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAuthUserProvider);
    final claimState = ref.watch(claimHistoryProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Claim History')),
        body: const Center(child: Text('User not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim History'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClaims,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(context, claimState),
    );
  }

  /// Task 12.4: Build body with loading/empty/error states
  Widget _buildBody(BuildContext context, ClaimHistoryState claimState) {
    // Loading state
    if (claimState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (claimState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load claims',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                claimState.error!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadClaims,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (claimState.claims.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No claims submitted yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Claims will appear here once submitted',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Task 12.2: Claims list
    return RefreshIndicator(
      onRefresh: () async {
        _loadClaims();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: claimState.claims.length,
        itemBuilder: (context, index) {
          final claim = claimState.claims[index];
          return ClaimCard(
            claim: claim,
            onTap: () {
              _showClaimDetailsModal(context, claim);
            },
          );
        },
      ),
    );
  }

  /// Task 12.3: Show claim details modal
  void _showClaimDetailsModal(BuildContext context, InsuranceClaim claim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ClaimDetailsModal(claim: claim),
    );
  }
}

/// Task 12.2: Claim card widget
class ClaimCard extends StatelessWidget {
  final InsuranceClaim claim;
  final VoidCallback onTap;

  const ClaimCard({
    super.key,
    required this.claim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with cattle ID and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cattle #${claim.cattleId.substring(0, 8)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Claim #${claim.id.substring(0, 12)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context, claim.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Loss type and submission date
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      icon: _getLossTypeIcon(claim.lossType),
                      label: 'Loss Type',
                      value: claim.lossType.label,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Submitted',
                      value: DateFormat('MMM d, y').format(claim.submittedDate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Claim amount and settlement
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: claim.isSettled
                      ? Colors.green.shade50
                      : claim.isRejected
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: claim.isSettled
                        ? Colors.green.shade200
                        : claim.isRejected
                            ? Colors.red.shade200
                            : Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Claim Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'KES ${claim.claimAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (claim.isSettled && claim.settlementAmount != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Settlement',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            'KES ${claim.settlementAmount!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
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

  Widget _buildStatusBadge(BuildContext context, ClaimStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case ClaimStatus.submitted:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        break;
      case ClaimStatus.underReview:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case ClaimStatus.approved:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case ClaimStatus.rejected:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;
      case ClaimStatus.settled:
        backgroundColor = Colors.teal.shade100;
        textColor = Colors.teal.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getLossTypeIcon(LossType type) {
    switch (type) {
      case LossType.death:
        return Icons.dangerous;
      case LossType.theft:
        return Icons.security;
      case LossType.disease:
        return Icons.medical_services;
    }
  }
}

/// Task 12.3: Claim details modal
class ClaimDetailsModal extends StatelessWidget {
  final InsuranceClaim claim;

  const ClaimDetailsModal({
    super.key,
    required this.claim,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Claim Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Claim information
                      _buildSection(
                        context,
                        title: 'Claim Information',
                        children: [
                          _buildDetailRow('Claim ID', claim.id),
                          _buildDetailRow('Policy ID', claim.policyId),
                          _buildDetailRow('Cattle ID', claim.cattleId),
                          _buildDetailRow('Loss Type', claim.lossType.label),
                          _buildDetailRow(
                            'Loss Date',
                            DateFormat('MMM d, y').format(claim.lossDate),
                          ),
                          _buildDetailRow(
                            'Submitted Date',
                            DateFormat('MMM d, y').format(claim.submittedDate),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _buildSection(
                        context,
                        title: 'Description',
                        children: [
                          Text(
                            claim.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Financial information
                      _buildSection(
                        context,
                        title: 'Financial Information',
                        children: [
                          _buildDetailRow(
                            'Claim Amount',
                            'KES ${claim.claimAmount.toStringAsFixed(0)}',
                          ),
                          if (claim.settlementAmount != null)
                            _buildDetailRow(
                              'Settlement Amount',
                              'KES ${claim.settlementAmount!.toStringAsFixed(0)}',
                            ),
                          if (claim.settlementDate != null)
                            _buildDetailRow(
                              'Settlement Date',
                              DateFormat('MMM d, y').format(claim.settlementDate!),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status timeline
                      _buildSection(
                        context,
                        title: 'Status Timeline',
                        children: [
                          ...claim.statusUpdates.map((update) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(update.status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          update.status.label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('MMM d, y - HH:mm')
                                              .format(update.date),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        if (update.comment.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            update.comment,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Review comments
                      if (claim.reviewComments != null &&
                          claim.reviewComments!.isNotEmpty)
                        _buildSection(
                          context,
                          title: 'Review Comments',
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                claim.reviewComments!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // Supporting documents
                      if (claim.supportingDocuments.isNotEmpty)
                        _buildSection(
                          context,
                          title: 'Supporting Documents',
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: claim.supportingDocuments.length,
                              itemBuilder: (context, index) {
                                final docUrl = claim.supportingDocuments[index];
                                return InkWell(
                                  onTap: () {
                                    // TODO: Open document viewer
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('View document: $docUrl'),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        docUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.insert_drive_file,
                                            size: 40,
                                            color: Colors.grey.shade400,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.submitted:
        return Colors.blue;
      case ClaimStatus.underReview:
        return Colors.orange;
      case ClaimStatus.approved:
        return Colors.green;
      case ClaimStatus.rejected:
        return Colors.red;
      case ClaimStatus.settled:
        return Colors.teal;
    }
  }
}
