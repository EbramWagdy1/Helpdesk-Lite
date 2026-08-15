import 'package:get_it/get_it.dart';
import 'package:helpdesk/core/services/storage_service.dart';
import 'package:helpdesk/features/auth/data/auth_repository.dart';
import 'package:helpdesk/features/tickets/data/ticket_repository.dart';

final GetIt sl = GetIt.instance;

void setupServiceLocator() {
  // Services
  if (!sl.isRegistered<StorageService>()) {
    sl.registerLazySingleton<StorageService>(() => StorageService());
  }

  // Repositories
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  }

  if (!sl.isRegistered<TicketRepository>()) {
    sl.registerLazySingleton<TicketRepository>(() => TicketRepository());
  }
}
