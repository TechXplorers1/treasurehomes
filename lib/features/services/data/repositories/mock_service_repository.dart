import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/service_entity.dart';

abstract class ServiceRepository {
  Future<List<ServiceEntity>> getServices();
  Future<ServiceEntity> getServiceById(String id);
  Future<List<ServiceEntity>> getServicesByCategory(String category);
}

class MockServiceRepository implements ServiceRepository {
  final List<ServiceEntity> _services = [
    const ServiceEntity(
      id: '1',
      name: 'Standard AC Service',
      description: 'Comprehensive cleaning and maintenance of your AC unit.',
      price: 50.0,
      category: 'HVAC',
      rating: 4.8,
    ),
    const ServiceEntity(
      id: '2',
      name: 'Pipe Leakage Repair',
      description: 'Fixing leaks in pipes and faucets.',
      price: 40.0,
      category: 'Plumbing',
      rating: 4.5,
    ),
    const ServiceEntity(
      id: '3',
      name: 'Full House Cleaning',
      description: 'Deep cleaning for every corner of your house.',
      price: 120.0,
      category: 'Cleaning',
      rating: 4.9,
    ),
    const ServiceEntity(
      id: '4',
      name: 'Switchboard Installation',
      description: 'Installation of new switchboards and sockets.',
      price: 30.0,
      category: 'Electrical',
      rating: 4.7,
    ),
    const ServiceEntity(
      id: '5',
      name: 'Home Remodeling',
      description:
          'Complete home remodeling services including kitchen and bathroom renovations.',
      price: 1500.0,
      category: 'Remodeling',
      rating: 4.9,
    ),
    const ServiceEntity(
      id: '6',
      name: 'Home Addition & Extension',
      description:
          'Expand your living space with our expert home addition and extension services.',
      price: 5000.0,
      category: 'Remodeling',
      rating: 5.0,
    ),
  ];

  @override
  Future<List<ServiceEntity>> getServices() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _services;
  }

  @override
  Future<ServiceEntity> getServiceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _services.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Service not found'),
    );
  }

  @override
  Future<List<ServiceEntity>> getServicesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _services.where((s) => s.category == category).toList();
  }
}

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return MockServiceRepository();
});

final servicesProvider = FutureProvider<List<ServiceEntity>>((ref) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getServices();
});
