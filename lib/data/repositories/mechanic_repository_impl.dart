import 'package:scheduling_app/data/datasources/firestore_mechanic_datasource.dart';
import 'package:scheduling_app/data/models/mechanic_model.dart';
import 'package:scheduling_app/domain/entities/mechanic.dart';
import 'package:scheduling_app/domain/entities/mechanic_availability.dart';
import 'package:scheduling_app/domain/repositories/mechanic_repository.dart';

class MechanicRepositoryImpl implements MechanicRepository {
  final FirestoreMechanicDatasource datasource;

  MechanicRepositoryImpl({required this.datasource});

  @override
  Future<List<Mechanic>> getMechanics() async {
    final models = await datasource.getMechanics();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Mechanic?> getMechanicById(String mechanicId) async {
    final model = await datasource.getMechanicById(mechanicId);
    return model?.toEntity();
  }

  @override
  Future<void> createMechanic(Mechanic mechanic) async {
    final model = MechanicModel.fromEntity(mechanic);
    await datasource.createMechanic(model);
  }

  @override
  Future<void> updateMechanic(Mechanic mechanic) async {
    final model = MechanicModel.fromEntity(mechanic);
    await datasource.updateMechanic(model);
  }

  @override
  Future<void> updateMechanicAvailability(
    String mechanicId,
    List<DayAvailability> availability,
  ) async {
    await datasource.updateMechanicAvailability(mechanicId, availability);
  }

  @override
  Stream<List<Mechanic>> watchMechanics() {
    return datasource.watchMechanics().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}
