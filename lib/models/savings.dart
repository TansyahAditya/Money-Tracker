import 'package:drift/drift.dart';

@DataClassName('Saving')
class Savings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 128)();
  IntColumn get targetAmount => integer()();
  IntColumn get currentAmount => integer().withDefault(const Constant(0))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get icon => text().withDefault(const Constant('savings'))();
  IntColumn get color => integer().withDefault(const Constant(0xFF4CAF50))();
  
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
