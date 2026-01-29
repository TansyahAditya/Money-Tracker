import 'package:drift/drift.dart';

/// CashBalance table for tracking cash/saldo movements
/// type: 1 = Cash In, 2 = Cash Out
@DataClassName('CashBalanceEntry')
class CashBalances extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().withLength(max: 250)();
  IntColumn get amount => integer()();
  IntColumn get type => integer()(); // 1 = in, 2 = out
  IntColumn get balanceAfter => integer()();
  DateTimeColumn get transactionDate => dateTime()();
  
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/*
  Type:
  1. Cash In (Uang Masuk)
  2. Cash Out (Uang Keluar)
*/
