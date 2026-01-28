import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:money_tracker/models/category.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/models/transaction_with_category.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Categories, Transactions],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  // --------------------------
  // CATEGORY CRUD FUNCTIONS
  // --------------------------

  Future<List<Category>> getAllCategoryRepo(int type) async {
    return await (select(categories)
      ..where((tbl) => tbl.type.equals(type))).get();
  }

  Future updateCategoryRepo(int id, String newName) async {
    return (update(categories)
          ..where((t) => t.id.equals(id)))
        .write(CategoriesCompanion(name: Value(newName)));
  }

  Future deleteCategoryRepo(int id) async {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }

  // --------------------------
  // TRANSACTION CRUD FUNCTIONS
  // --------------------------

  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(DateTime date) {
    // Convert date to start and end of day to ensure we get all transactions for that day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id)),
    ])
      ..where(transactions.transaction_date.isBetweenValues(startOfDay, endOfDay))
      ..orderBy([OrderingTerm.desc(transactions.transaction_date)])
    );

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }

  // New method for getting transactions by date range
  Stream<List<TransactionWithCategory>> getTransactionsByDateRangeRepo(DateTime startDate, DateTime endDate) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id)),
    ])
      ..where(transactions.transaction_date.isBetweenValues(startDate, endDate))
      ..orderBy([OrderingTerm.desc(transactions.transaction_date)])
    );

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }

  // Method to get all transactions (useful for yearly view or statistics)
  Stream<List<TransactionWithCategory>> getAllTransactionsRepo() {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id)),
    ])..orderBy([OrderingTerm.desc(transactions.transaction_date)]));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }

  // Method to get transactions by specific month and year
  Stream<List<TransactionWithCategory>> getTransactionsByMonthRepo(int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    
    return getTransactionsByDateRangeRepo(startOfMonth, endOfMonth);
  }

  // Method to get transactions by specific year
  Stream<List<TransactionWithCategory>> getTransactionsByYearRepo(int year) {
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year, 12, 31, 23, 59, 59, 999);
    
    return getTransactionsByDateRangeRepo(startOfYear, endOfYear);
  }

  // Method to get transactions by week (Monday to Sunday)
  Stream<List<TransactionWithCategory>> getTransactionsByWeekRepo(DateTime date) {
    // Calculate start of week (Monday)
    int daysFromMonday = date.weekday - 1;
    final startOfWeek = DateTime(date.year, date.month, date.day - daysFromMonday);
    final endOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + 6, 23, 59, 59, 999);
    
    return getTransactionsByDateRangeRepo(startOfWeek, endOfWeek);
  }

  // Helper method to get transaction summary for a specific period
  Future<Map<String, int>> getTransactionSummaryByDateRange(DateTime startDate, DateTime endDate) async {
    final transactions = await getTransactionsByDateRangeRepo(startDate, endDate).first;
    
    int totalIncome = 0;
    int totalExpense = 0;
    
    for (var transaction in transactions) {
      if (transaction.category.type == 1) {
        totalIncome += transaction.transaction.amount;
      } else {
        totalExpense += transaction.transaction.amount;
      }
    }
    
    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }

  // Method to get monthly summary for a specific year (useful for charts)
  Future<List<Map<String, dynamic>>> getMonthlySummaryByYear(int year) async {
    List<Map<String, dynamic>> monthlySummary = [];
    
    for (int month = 1; month <= 12; month++) {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59, 999);
      
      final summary = await getTransactionSummaryByDateRange(startOfMonth, endOfMonth);
      
      monthlySummary.add({
        'month': month,
        'monthName': _getMonthName(month),
        'income': summary['income'],
        'expense': summary['expense'],
        'balance': summary['balance'],
      });
    }
    
    return monthlySummary;
  }

  // Helper method to get month name in Indonesian
  String _getMonthName(int month) {
    const monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return monthNames[month - 1];
  }

  Future deleteTransactionRepo(int id) async {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  Future updateTransactionRepo(
    int id,
    String description,
    int categoryId,
    int amount,
    DateTime transactionDate,
    DateTime updatedAt,
  ) async {
    return await (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        description: Value(description),
        category_id: Value(categoryId),
        amount: Value(amount),
        transaction_date: Value(transactionDate),
        updated_at: Value(updatedAt),
      ),
    );
  }

  // Method to insert new transaction
  Future<int> insertTransactionRepo(TransactionsCompanion transaction) async {
    return await into(transactions).insert(transaction);
  }

  // Method to insert new category
  Future<int> insertCategoryRepo(CategoriesCompanion category) async {
    return await into(categories).insert(category);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}