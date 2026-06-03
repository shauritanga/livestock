import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/cattle_tracking/domain/entities/cattle.dart';
import 'package:livestock/features/cattle_tracking/presentation/providers/cattle_providers.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/farmer_management/presentation/providers/farmer_list_state_provider.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/presentation/providers/claim_submission_provider.dart';
import 'package:livestock/features/insurance/presentation/providers/policy_list_provider.dart';

/// Claim submission screen for submitting insurance claims
///
/// This screen allows collection agents to:
/// - Select a farmer and their active policy
/// - Choose the affected cattle
/// - Specify loss details
/// - Upload supporting documents
/// - Submit the claim
///
/// Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7
class ClaimSubmissionScreen extends ConsumerStatefulWidget {
  const ClaimSubmissionScreen({super.key});

  @override
  ConsumerState<ClaimSubmissionScreen> createState() =>
      _ClaimSubmissionScreenState();
}

class _ClaimSubmissionScreenState extends ConsumerState<ClaimSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _showFarmerSearch = false;
  List<InsurancePolicy> _farmerPolicies = [];
  List<Cattle> _coveredCattle = [];
  bool _loadingPolicies = false;
  bool _loadingCattle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFarmers();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadFarmers() {
    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    if (user.role.name == 'collection_agent' &&
        user.collectionCentreId != null) {
      ref.read(farmerListProvider.notifier).loadFarmersByCollectionCentre(
            user.collectionCentreId!,
          );
    } else if (user.cooperativeId != null) {
      ref.read(farmerListProvider.notifier).loadFarmersByCooperative(
            user.cooperativeId!,
          );
    }
  }

  Future<void> _loadFarmerPolicies(String farmerId) async {
    setState(() {
      _loadingPolicies = true;
      _farmerPolicies = [];
    });

    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    // Load policies for the farmer
    await ref.read(policyListProvider.notifier).loadPolicies(
          farmerId,
          cooperativeId: user.cooperativeId!,
        );

    final policyState = ref.read(policyListProvider);
    setState(() {
      _farmerPolicies = policyState.policies
          .where((p) => p.status == PolicyStatus.active)
          .toList();
      _loadingPolicies = false;
    });
  }

  Future<void> _loadCoveredCattle(InsurancePolicy policy) async {
    setState(() {
      _loadingCattle = true;
      _coveredCattle = [];
    });

    final useCase = ref.read(listFarmerCattleUseCaseProvider);
    final result = await useCase(policy.farmerId);

    switch (result) {
      case Success(value: final allCattle):
        setState(() {
          _coveredCattle = allCattle
              .where((c) => policy.coveredCattleIds.contains(c.id))
              .toList();
          _loadingCattle = false;
        });
      case Error():
        setState(() {
          _coveredCattle = [];
          _loadingCattle = false;
        });
    }
  }

  void _selectFarmer(Farmer farmer) {
    ref.read(claimSubmissionProvider.notifier).selectFarmer(farmer);
    setState(() {
      _showFarmerSearch = false;
    });
    _loadFarmerPolicies(farmer.id);
  }

  void _selectPolicy(InsurancePolicy policy) {
    ref.read(claimSubmissionProvider.notifier).selectPolicy(policy);
    _loadCoveredCattle(policy);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        ref
            .read(claimSubmissionProvider.notifier)
            .addDocument(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAuthUserProvider);
    final claimState = ref.watch(claimSubmissionProvider);
    final farmerListState = ref.watch(farmerListProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Submit Claim')),
        body: const Center(child: Text('User not authenticated')),
      );
    }

    // Show success dialog
    if (claimState.submissionSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessDialog(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Insurance Claim'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Task 11.2: Farmer and policy selection
                  _buildFarmerSelectionSection(context, claimState),
                  const SizedBox(height: 16),

                  if (claimState.selectedFarmer != null) ...[
                    _buildPolicySelectionSection(context, claimState),
                    const SizedBox(height: 16),
                  ],

                  // Task 11.3: Claim details form
                  if (claimState.selectedPolicy != null) ...[
                    _buildClaimDetailsForm(context, claimState),
                    const SizedBox(height: 16),

                    // Task 11.4: Document upload section
                    _buildDocumentUploadSection(context, claimState),
                    const SizedBox(height: 24),

                    // Task 11.5: Submit button
                    _buildSubmitButton(context, claimState, user),
                  ],

                  // Error message
                  if (claimState.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              claimState.error!,
                              style: TextStyle(color: Colors.red.shade700),
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

          // Farmer search overlay
          if (_showFarmerSearch)
            _buildFarmerSearchOverlay(context, farmerListState),

          // Loading overlay
          if (claimState.isSubmitting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Submitting claim...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Task 11.2: Build farmer selection section
  Widget _buildFarmerSelectionSection(
    BuildContext context,
    ClaimSubmissionState claimState,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _showFarmerSearch = true;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: claimState.selectedFarmer == null
              ? Row(
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 40,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.6),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Farmer',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to search and select a farmer',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Text(
                            claimState.selectedFarmer!.name
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                claimState.selectedFarmer!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                claimState.selectedFarmer!.phoneNumber,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showFarmerSearch = true;
                            });
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Task 11.2: Build policy selection section
  Widget _buildPolicySelectionSection(
    BuildContext context,
    ClaimSubmissionState claimState,
  ) {
    if (_loadingPolicies) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_farmerPolicies.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.shield_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No active policies',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'This farmer has no active insurance policies',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Policy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ..._farmerPolicies.map((policy) {
              final isSelected = claimState.selectedPolicy?.id == policy.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                      : null,
                ),
                child: RadioListTile<String>(
                  value: policy.id,
                  groupValue: claimState.selectedPolicy?.id,
                  onChanged: (value) => _selectPolicy(policy),
                  title: Text(
                    'Policy #${policy.id.substring(0, 12)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${policy.coveredCattleIds.length} cattle covered',
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Task 11.3: Build claim details form
  Widget _buildClaimDetailsForm(
    BuildContext context,
    ClaimSubmissionState claimState,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Claim Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Cattle selection
            if (_loadingCattle)
              const Center(child: CircularProgressIndicator())
            else if (_coveredCattle.isEmpty)
              Text(
                'No covered cattle found',
                style: TextStyle(color: Colors.grey[600]),
              )
            else
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Cattle *',
                  border: OutlineInputBorder(),
                ),
                initialValue: claimState.selectedCattleId,
                items: _coveredCattle.map((cattle) {
                  return DropdownMenuItem(
                    value: cattle.id,
                    child: Text(
                      'Cattle #${cattle.id.substring(0, 8)} - ${cattle.breed}',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(claimSubmissionProvider.notifier)
                        .selectCattle(value);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a cattle';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 16),

            // Loss type selection
            DropdownButtonFormField<LossType>(
              decoration: const InputDecoration(
                labelText: 'Loss Type *',
                border: OutlineInputBorder(),
              ),
              initialValue: claimState.lossType,
              items: LossType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getLossTypeIcon(type), size: 20),
                      const SizedBox(width: 12),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(claimSubmissionProvider.notifier).setLossType(value);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a loss type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Loss date picker
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: claimState.lossDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  ref.read(claimSubmissionProvider.notifier).setLossDate(date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Loss Date *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  claimState.lossDate != null
                      ? DateFormat('MMM d, y').format(claimState.lossDate!)
                      : 'Select date',
                  style: TextStyle(
                    color: claimState.lossDate != null
                        ? Colors.black
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe the circumstances of the loss...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              onChanged: (value) {
                ref
                    .read(claimSubmissionProvider.notifier)
                    .setDescription(value);
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a description';
                }
                if (value.trim().length < 20) {
                  return 'Description must be at least 20 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Task 11.4: Build document upload section
  Widget _buildDocumentUploadSection(
    BuildContext context,
    ClaimSubmissionState claimState,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supporting Documents',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload photos or documents to support your claim',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),

            // Upload button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Upload Document'),
              ),
            ),
            const SizedBox(height: 16),

            // Uploaded documents list
            if (claimState.uploadedDocuments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No documents uploaded yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: claimState.uploadedDocuments.length,
                itemBuilder: (context, index) {
                  final doc = claimState.uploadedDocuments[index];
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            doc,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(claimSubmissionProvider.notifier)
                                .removeDocument(index);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Task 11.5: Build submit button
  Widget _buildSubmitButton(
    BuildContext context,
    ClaimSubmissionState claimState,
    dynamic user,
  ) {
    return ElevatedButton.icon(
      onPressed: claimState.isSubmitting
          ? null
          : () async {
              if (_formKey.currentState!.validate()) {
                await ref
                    .read(claimSubmissionProvider.notifier)
                    .submitClaim(
                      cooperativeId: user.cooperativeId!,
                    );
              }
            },
      icon: const Icon(Icons.send),
      label: const Text('Submit Claim'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  /// Build farmer search overlay
  Widget _buildFarmerSearchOverlay(
    BuildContext context,
    dynamic farmerListState,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AppBar(
            title: const Text('Select Farmer'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showFarmerSearch = false;
                });
              },
            ),
          ),
          Expanded(
            child: farmerListState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : farmerListState.farmers.isEmpty
                    ? const Center(child: Text('No farmers found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: farmerListState.farmers.length,
                        itemBuilder: (context, index) {
                          final farmer = farmerListState.farmers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Text(
                                  farmer.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                farmer.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(farmer.phoneNumber),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 16),
                              onTap: () => _selectFarmer(farmer),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 64,
        ),
        title: const Text('Claim Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your insurance claim has been successfully submitted.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'The farmer will be notified and the claim will be reviewed by the insurance partner.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(claimSubmissionProvider.notifier).reset();
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
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
