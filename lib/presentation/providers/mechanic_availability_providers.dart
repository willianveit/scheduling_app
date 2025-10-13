import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduling_app/data/datasources/firestore_mechanic_availability_datasource.dart';
import 'package:scheduling_app/data/repositories/mechanic_availability_repository_impl.dart';
import 'package:scheduling_app/domain/repositories/mechanic_availability_repository.dart';
import 'package:scheduling_app/presentation/providers/firebase_providers.dart';

// Datasource provider
final mechanicAvailabilityDatasourceProvider = Provider<FirestoreMechanicAvailabilityDatasource>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreMechanicAvailabilityDatasource(firestore: firestore);
});

// Repository provider
final mechanicAvailabilityRepositoryProvider = Provider<MechanicAvailabilityRepository>((ref) {
  final datasource = ref.watch(mechanicAvailabilityDatasourceProvider);
  return MechanicAvailabilityRepositoryImpl(datasource: datasource);
});
