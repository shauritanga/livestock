import 'dart:io';

import 'package:livestock/core/errors/exceptions.dart';
import 'package:livestock/core/errors/failures.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/insurance/data/datasources/insurance_remote_datasource.dart';
import 'package:livestock/features/insurance/domain/entities/entities.dart';
import 'package:livestock/features/insurance/domain/repositories/insurance_repository.dart';

/// Implementation of InsuranceRepository
/// 
/// This class implements the repository interface by delegating to the
/// remote data source and converting exceptions to failures.
/// 
/// Note: Some methods require farmerId context which should be passed
/// from the use case layer. Methods that need farmerId but don't have it
/// in the interface are marked as UnimplementedError with guidance.
class InsuranceRepositoryImpl implements InsuranceRepository {
  final InsuranceRemoteDataSource remoteDataSource;
  
  // Context that should be injected or retrieved from auth state
  final String cooperativeId;

  InsuranceRepositoryImpl({
    required this.remoteDataSource,
    required this.cooperativeId,
  });
  
  // Helper to store farmerId context for methods that need it
  // This is a workaround for the interface limitation
  String? _currentFarmerId;
  
  /// Set the current farmer context for operations
  void setFarmerContext(String farmerId) {
    _currentFarmerId = farmerId;
  }
  
  /// Clear the farmer context
  void clearFarmerContext() {
    _currentFarmerId = null;
  }

  // ==================== Policy Management ====================

  @override
  Future<Result<InsurancePolicy>> createPolicy({
    required String farmerId,
    required List<String> cattleIds,
    required double totalPremium,
    required PaymentFrequency paymentFrequency,
  }) async {
    try {
      final policy = await remoteDataSource.createPolicy(
        farmerId: farmerId,
        cooperativeId: cooperativeId,
        cattleIds: cattleIds,
        totalPremium: totalPremium,
        paymentFrequency: paymentFrequency,
      );
      return Success(policy.toEntity());
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<InsurancePolicy>> getPolicy(String policyId) async {
    try {
      if (_currentFarmerId == null) {
        return const Error(
          ValidationFailure(
            'Farmer context not set. Call setFarmerContext() first.',
          ),
        );
      }
      
      final policy = await remoteDataSource.getPolicy(policyId);
      return Success(policy.toEntity());
    } on NotFoundException catch (e) {
      return Error(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<InsurancePolicy>>> getFarmerPolicies(
    String farmerId,
  ) async {
    try {
      final policies = await remoteDataSource.getFarmerPolicies(farmerId);
      return Success(
        policies.map((model) => model.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<InsurancePolicy>>> getPoliciesByStatus(
    PolicyStatus status,
  ) async {
    try {
      // This would require a collection group query or iterating through farmers
      // For now, we'll throw an error
      throw UnimplementedError(
        'getPoliciesByStatus requires collection group query implementation',
      );
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<InsurancePolicy>> updatePolicyStatus(
    String policyId,
    PolicyStatus status,
  ) async {
    try {
      if (_currentFarmerId == null) {
        return const Error(
          ValidationFailure(
            'Farmer context not set. Call setFarmerContext() first.',
          ),
        );
      }
      
      final policy = await remoteDataSource.updatePolicyStatus(
        policyId,
        status,
      );
      return Success(policy.toEntity());
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  // ==================== Premium Calculation ====================

  @override
  Future<Result<PremiumCalculation>> calculatePremium({
    required String farmerId,
    required List<String> cattleIds,
  }) async {
    try {
      final calculation = await remoteDataSource.calculatePremium(
        cattleIds: cattleIds,
      );
      return Success(calculation);
    } on NotFoundException catch (e) {
      return Error(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  // ==================== Premium Payments ====================

  @override
  Future<Result<void>> recordPremiumPayment({
    required String policyId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? milkDeliveryId,
  }) async {
    try {
      if (_currentFarmerId == null) {
        return const Error(
          ValidationFailure(
            'Farmer context not set. Call setFarmerContext() first.',
          ),
        );
      }
      
      await remoteDataSource.recordPremiumPayment(
        policyId: policyId,
        amount: amount,
        paymentMethod: paymentMethod,
        milkDeliveryId: milkDeliveryId,
      );
      return const Success(null);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on NotFoundException catch (e) {
      return Error(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<PremiumPayment>>> getPolicyPayments(
    String policyId,
  ) async {
    try {
      if (_currentFarmerId == null) {
        return const Error(
          ValidationFailure(
            'Farmer context not set. Call setFarmerContext() first.',
          ),
        );
      }
      
      final payments = await remoteDataSource.getPolicyPayments(policyId);
      return Success(
        payments.map((model) => model.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  // ==================== Claims Management ====================

  @override
  Future<Result<InsuranceClaim>> createClaim({
    required String policyId,
    required String cattleId,
    required LossType lossType,
    required DateTime lossDate,
    required String description,
    required List<String> supportingDocuments,
  }) async {
    try {
      if (_currentFarmerId == null) {
        return const Error(
          ValidationFailure(
            'Farmer context not set. Call setFarmerContext() first.',
          ),
        );
      }
      
      final claim = await remoteDataSource.createClaim(
        policyId: policyId,
        farmerId: _currentFarmerId!,
        cattleId: cattleId,
        lossType: lossType,
        lossDate: lossDate,
        description: description,
        supportingDocuments: supportingDocuments,
      );
      return Success(claim.toEntity());
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<InsuranceClaim>> getClaim(String claimId) async {
    try {
      // Note: This requires policyId which we don't have in the interface
      // In practice, use getFarmerClaims and filter by claimId
      return const Error(
        ValidationFailure(
          'getClaim not implemented. Use getFarmerClaims and filter by ID.',
        ),
      );
    } on NotFoundException catch (e) {
      return Error(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<InsuranceClaim>>> getFarmerClaims(
    String farmerId,
  ) async {
    try {
      final claims = await remoteDataSource.getFarmerClaims(farmerId);
      return Success(
        claims.map((model) => model.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<InsuranceClaim>>> getPolicyClaims(
    String policyId,
  ) async {
    try {
      if (_currentFarmerId == null) {
        return const Error(
          ValidationFailure(
            'Farmer context not set. Call setFarmerContext() first.',
          ),
        );
      }
      
      final claims = await remoteDataSource.getPolicyClaims(policyId);
      return Success(
        claims.map((model) => model.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  // ==================== Document Management ====================

  @override
  Future<Result<String>> uploadDocument(File document) async {
    try {
      if (_currentFarmerId == null) {
        return const Error(
          ValidationFailure(
            'Farmer context not set. Call setFarmerContext() first.',
          ),
        );
      }
      
      final url = await remoteDataSource.uploadDocument(
        document,
        _currentFarmerId!,
      );
      return Success(url);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  // ==================== Premium Rates ====================

  @override
  Future<Result<List<PremiumRate>>> getPremiumRates() async {
    try {
      final rates = await remoteDataSource.getPremiumRates();
      return Success(
        rates.map((model) => model.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }
}
