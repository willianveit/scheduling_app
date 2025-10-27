import 'package:scheduling_app/domain/entities/mechanic.dart';
import 'package:scheduling_app/domain/entities/mechanic_availability.dart';

abstract class MechanicRepository {
  Future<List<Mechanic>> getMechanics();
  Future<Mechanic?> getMechanicById(String mechanicId);
  Future<void> createMechanic(Mechanic mechanic);
  Future<void> updateMechanic(Mechanic mechanic);
  Future<void> updateMechanicAvailability(String mechanicId, List<DayAvailability> availability);
  Stream<List<Mechanic>> watchMechanics();
}
