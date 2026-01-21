import '../entities/service_entity.dart';

abstract class ServiceRepository {
  Future<List<ServiceEntity>> getServices();
  Future<ServiceEntity> getServiceById(String id);

  Future<void> addService(ServiceEntity service);
  Future<void> updateService(ServiceEntity service);
  Future<void> deleteService(String id);
}
