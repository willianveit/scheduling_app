import 'package:scheduling_app/domain/entities/mechanic_availability.dart';

abstract class MechanicAvailabilityRepository {
  Future<MechanicAvailability?> getMechanicAvailability(String mechanicId);
  Future<void> saveMechanicAvailability(MechanicAvailability availability);
  Future<void> deleteMechanicAvailability(String mechanicId);
  Stream<MechanicAvailability?> watchMechanicAvailability(String mechanicId);
}
