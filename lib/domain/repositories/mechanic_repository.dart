import 'package:scheduling_app/domain/entities/mechanic.dart';

abstract class MechanicRepository {
  Future<List<Mechanic>> getMechanics();
  Future<Mechanic?> getMechanicById(String mechanicId);
  Future<void> createMechanic(Mechanic mechanic);
  Stream<List<Mechanic>> watchMechanics();
}
