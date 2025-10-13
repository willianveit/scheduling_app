import 'package:scheduling_app/data/datasources/firestore_mechanic_availability_datasource.dart';
import 'package:scheduling_app/data/models/mechanic_availability_model.dart';
import 'package:scheduling_app/domain/entities/mechanic_availability.dart';
import 'package:scheduling_app/domain/repositories/mechanic_availability_repository.dart';

class MechanicAvailabilityRepositoryImpl implements MechanicAvailabilityRepository {
  final FirestoreMechanicAvailabilityDatasource datasource;

  MechanicAvailabilityRepositoryImpl({required this.datasource});

  @override
  Future<MechanicAvailability?> getMechanicAvailability(String mechanicId) async {
    final model = await datasource.getMechanicAvailability(mechanicId);
    return model?.toEntity();
  }

  @override
  Future<void> saveMechanicAvailability(MechanicAvailability availability) async {
    final model = MechanicAvailabilityModel.fromEntity(availability);
    await datasource.saveMechanicAvailability(model);
  }

  @override
  Future<void> deleteMechanicAvailability(String mechanicId) async {
    await datasource.deleteMechanicAvailability(mechanicId);
  }

  @override
  Stream<MechanicAvailability?> watchMechanicAvailability(String mechanicId) {
    return datasource.watchMechanicAvailability(mechanicId).map((model) => model?.toEntity());
  }
}
