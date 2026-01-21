import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';
import '../../data/repositories/firestore_service_repository.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return FirestoreServiceRepository();
});

final servicesProvider = FutureProvider<List<ServiceEntity>>((ref) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getServices();
});
