import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livestock/core/utils/result.dart';
import 'package:livestock/features/auth/presentation/providers/auth_providers.dart';
import 'package:livestock/features/off_takers/data/datasources/off_taker_remote_datasource.dart';
import 'package:livestock/features/off_takers/data/repositories/off_taker_repository_impl.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker.dart';
import 'package:livestock/features/off_takers/domain/entities/off_taker_category.dart';
import 'package:livestock/features/off_takers/domain/repositories/off_taker_repository.dart';
import 'package:livestock/features/off_takers/domain/usecases/create_off_taker.dart';
import 'package:livestock/features/off_takers/domain/usecases/get_all_off_takers.dart';
import 'package:livestock/features/off_takers/domain/usecases/get_off_taker_by_id.dart';

// Data source provider
final offTakerRemoteDataSourceProvider = Provider<OffTakerRemoteDataSource>((ref) {
  return OffTakerRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

// Repository provider
final offTakerRepositoryProvider = Provider<OffTakerRepository>((ref) {
  final remoteDataSource = ref.watch(offTakerRemoteDataSourceProvider);
  final currentUser = ref.watch(currentAuthUserProvider);
  
  return OffTakerRepositoryImpl(
    remoteDataSource: remoteDataSource,
    cooperativeId: currentUser?.cooperativeId ?? '',
  );
});

// Use case providers
final createOffTakerUseCaseProvider = Provider<CreateOffTaker>((ref) {
  final repository = ref.watch(offTakerRepositoryProvider);
  return CreateOffTaker(repository);
});

final getAllOffTakersUseCaseProvider = Provider<GetAllOffTakers>((ref) {
  final repository = ref.watch(offTakerRepositoryProvider);
  return GetAllOffTakers(repository);
});

final getOffTakerByIdUseCaseProvider = Provider<GetOffTakerById>((ref) {
  final repository = ref.watch(offTakerRepositoryProvider);
  return GetOffTakerById(repository);
});

// Category filter notifier
class SelectedOffTakerCategoryNotifier extends Notifier<OffTakerCategory?> {
  @override
  OffTakerCategory? build() => null;

  void setCategory(OffTakerCategory? category) {
    state = category;
  }

  void clear() {
    state = null;
  }
}

final selectedOffTakerCategoryProvider = NotifierProvider<SelectedOffTakerCategoryNotifier, OffTakerCategory?>(() {
  return SelectedOffTakerCategoryNotifier();
});

// Off-takers list provider with category filtering
final offTakersProvider = FutureProvider<List<OffTaker>>((ref) async {
  final useCase = ref.watch(getAllOffTakersUseCaseProvider);
  final category = ref.watch(selectedOffTakerCategoryProvider);
  final currentUser = ref.watch(currentAuthUserProvider);

  if (currentUser?.cooperativeId == null) {
    return [];
  }

  final result = await useCase(category: category);

  return switch (result) {
    Success(value: final offTakers) => offTakers,
    Error() => [],
  };
});

// Selected off-taker provider (for sales screen integration)
class SelectedOffTakerNotifier extends Notifier<OffTaker?> {
  @override
  OffTaker? build() => null;

  void select(OffTaker? offTaker) {
    state = offTaker;
  }

  void clear() {
    state = null;
  }
}

final selectedOffTakerProvider = NotifierProvider<SelectedOffTakerNotifier, OffTaker?>(() {
  return SelectedOffTakerNotifier();
});

// Off-taker by ID provider
final offTakerByIdProvider = FutureProvider.family<OffTaker?, String>((ref, id) async {
  final useCase = ref.watch(getOffTakerByIdUseCaseProvider);
  final currentUser = ref.watch(currentAuthUserProvider);

  if (currentUser?.cooperativeId == null) {
    return null;
  }

  final result = await useCase(id);

  return switch (result) {
    Success(value: final offTaker) => offTaker,
    Error() => null,
  };
});

// Active off-takers provider (for sales screen dropdown)
final activeOffTakersProvider = FutureProvider<List<OffTaker>>((ref) async {
  final allOffTakers = await ref.watch(offTakersProvider.future);
  return allOffTakers.where((offTaker) => offTaker.isActive).toList();
});
