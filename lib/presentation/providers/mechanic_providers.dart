import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduling_app/data/datasources/firestore_mechanic_datasource.dart';
import 'package:scheduling_app/data/repositories/mechanic_repository_impl.dart';
import 'package:scheduling_app/domain/entities/mechanic.dart';
import 'package:scheduling_app/domain/repositories/mechanic_repository.dart';
import 'package:scheduling_app/presentation/providers/firebase_providers.dart';

// Datasource provider
final mechanicDatasourceProvider = Provider<FirestoreMechanicDatasource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreMechanicDatasource(firestore: firestore);
});

// Repository provider
final mechanicRepositoryProvider = Provider<MechanicRepository>((ref) {
  final datasource = ref.watch(mechanicDatasourceProvider);
  return MechanicRepositoryImpl(datasource: datasource);
});

// Stream provider to watch mechanics
final mechanicsStreamProvider = StreamProvider<List<Mechanic>>((ref) {
  final repository = ref.watch(mechanicRepositoryProvider);
  return repository.watchMechanics();
});

// Future provider to get mechanics once
final mechanicsProvider = FutureProvider<List<Mechanic>>((ref) {
  final repository = ref.watch(mechanicRepositoryProvider);
  return repository.getMechanics();
});
