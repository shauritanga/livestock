import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/farmer_management/domain/entities/farmer.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/presentation/providers/insurance_providers.dart';

/// State for claim submission
class ClaimSubmissionState {
  final Farmer? selectedFarmer;
  final InsurancePolicy? selectedPolicy;
  final String? selectedCattleId;
  final LossType? lossType;
  final DateTime? lossDate;
  final String description;
  final List<File> uploadedDocuments;
  final bool isUploading;
  final bool isSubmitting;
  final String? error;
  final bool submissionSuccess;

  const ClaimSubmissionState({
    this.selectedFarmer,
    this.selectedPolicy,
    this.selectedCattleId,
    this.lossType,
    this.lossDate,
    this.description = '',
    this.uploadedDocuments = const [],
    this.isUploading = false,
    this.isSubmitting = false,
    this.error,
    this.submissionSuccess = false,
  });

  ClaimSubmissionState copyWith({
    Farmer? selectedFarmer,
    InsurancePolicy? selectedPolicy,
    String? selectedCattleId,
    LossType? lossType,
    DateTime? lossDate,
    String? description,
    List<File>? uploadedDocuments,
    bool? isUploading,
    bool? isSubmitting,
    String? error,
    bool? submissionSuccess,
  }) {
    return ClaimSubmissionState(
      selectedFarmer: selectedFarmer ?? this.selectedFarmer,
      selectedPolicy: selectedPolicy ?? this.selectedPolicy,
      selectedCattleId: selectedCattleId ?? this.selectedCattleId,
      lossType: lossType ?? this.lossType,
      lossDate: lossDate ?? this.lossDate,
      description: description ?? this.description,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      isUploading: isUploading ?? this.isUploading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
    );
  }
}

/// Notifier for claim submission
class ClaimSubmissionNotifier extends Notifier<ClaimSubmissionState> {
  @override
  ClaimSubmissionState build() {
    return const ClaimSubmissionState();
  }

  /// Select farmer
  void selectFarmer(Farmer farmer) {
    state = state.copyWith(
      selectedFarmer: farmer,
      selectedPolicy: null,
      selectedCattleId: null,
      error: null,
    );
  }

  /// Select policy
  void selectPolicy(InsurancePolicy policy) {
    state = state.copyWith(
      selectedPolicy: policy,
      selectedCattleId: null,
      error: null,
    );
  }

  /// Select cattle
  void selectCattle(String cattleId) {
    state = state.copyWith(
      selectedCattleId: cattleId,
      error: null,
    );
  }

  /// Set loss type
  void setLossType(LossType type) {
    state = state.copyWith(
      lossType: type,
      error: null,
    );
  }

  /// Set loss date
  void setLossDate(DateTime date) {
    state = state.copyWith(
      lossDate: date,
      error: null,
    );
  }

  /// Set description
  void setDescription(String description) {
    state = state.copyWith(
      description: description,
      error: null,
    );
  }

  /// Add document
  void addDocument(File document) {
    final documents = List<File>.from(state.uploadedDocuments);
    documents.add(document);
    state = state.copyWith(
      uploadedDocuments: documents,
      error: null,
    );
  }

  /// Remove document
  void removeDocument(int index) {
    final documents = List<File>.from(state.uploadedDocuments);
    documents.removeAt(index);
    state = state.copyWith(
      uploadedDocuments: documents,
    );
  }

  /// Submit claim
  Future<void> submitClaim({
    required String cooperativeId,
  }) async {
    // Validate
    if (state.selectedPolicy == null ||
        state.selectedCattleId == null ||
        state.lossType == null ||
        state.lossDate == null ||
        state.description.isEmpty) {
      state = state.copyWith(
        error: 'Please fill in all required fields',
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      error: null,
    );

    final useCase = ref.read(submitClaimUseCaseProvider(cooperativeId));

    final result = await useCase(
      policyId: state.selectedPolicy!.id,
      cattleId: state.selectedCattleId!,
      lossType: state.lossType!,
      lossDate: state.lossDate!,
      description: state.description,
      supportingDocuments: state.uploadedDocuments,
    );

    switch (result) {
      case Success():
        state = state.copyWith(
          isSubmitting: false,
          submissionSuccess: true,
        );
      case Error(failure: final failure):
        state = state.copyWith(
          isSubmitting: false,
          error: failure.message,
        );
    }
  }

  /// Reset state
  void reset() {
    state = const ClaimSubmissionState();
  }
}

/// Provider for claim submission state
final claimSubmissionProvider = NotifierProvider<ClaimSubmissionNotifier, ClaimSubmissionState>(
  ClaimSubmissionNotifier.new,
);
