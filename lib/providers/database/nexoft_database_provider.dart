import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contacts/repositories/database/abstract/database_interface_abstract.dart';
import 'package:contacts/repositories/database/nexoft_database.dart';

// All database interfaces should be implemented here
// Enforcing one and single database interface -> Singleton pattern
final databaseInterfaceProvider = Provider<DatabaseInterface>((ref) {
  return NexoftDatabase();
});
