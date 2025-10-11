import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduling_app/data/datasources/firestore_slot_datasource.dart';
import 'package:scheduling_app/presentation/providers/firebase_providers.dart';

// Firestore datasource provider
final firestoreSlotDatasourceProvider = Provider<FirestoreSlotDatasource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreSlotDatasource(firestore: firestore);
});
