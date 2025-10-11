import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduling_app/data/repositories/slot_repository_impl.dart';
import 'package:scheduling_app/domain/repositories/slot_repository.dart';
import 'package:scheduling_app/presentation/providers/datasource_providers.dart';

// Repository provider
final slotRepositoryProvider = Provider<SlotRepository>((ref) {
  final datasource = ref.watch(firestoreSlotDatasourceProvider);
  return SlotRepositoryImpl(datasource: datasource);
});
