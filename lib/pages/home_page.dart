import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/models/transaction_with_category.dart';
import 'package:money_tracker/pages/transaction_page.dart';

enum TimePeriod { daily, weekly, monthly, yearly }

class HomePage extends StatefulWidget {
  final DateTime selectedDate;

  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase database = AppDatabase();

  int totalIncome = 0;
  int totalExpense = 0;
  TimePeriod selectedPeriod = TimePeriod.daily;
  Stream<List<TransactionWithCategory>>? _transactionStream;
  Map<String, int> expenseByCategory = {};
  Map<String, int> incomeByCategory = {};

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.key != widget.key) {
      _initializeStream();
    }
  }

  void _initializeStream() {
    if (selectedPeriod == TimePeriod.daily) {
      _transactionStream = database.getTransactionByDateRepo(
        widget.selectedDate,
      );
    } else {
      DateTime startDate = getStartDate(widget.selectedDate, selectedPeriod);
      DateTime endDate = getEndDate(widget.selectedDate, selectedPeriod);
      _transactionStream = database.getTransactionsByDateRangeRepo(
        startDate,
        endDate,
      );
    }
  }

  void refreshData() {
    _initializeStream();
    setState(() {});
  }

  DateTime getStartDate(DateTime date, TimePeriod period) {
    switch (period) {
      case TimePeriod.daily:
        return DateTime(date.year, date.month, date.day);
      case TimePeriod.weekly:
        int daysFromMonday = date.weekday - 1;
        return date.subtract(Duration(days: daysFromMonday));
      case TimePeriod.monthly:
        return DateTime(date.year, date.month, 1);
      case TimePeriod.yearly:
        return DateTime(date.year, 1, 1);
    }
  }

  DateTime getEndDate(DateTime date, TimePeriod period) {
    switch (period) {
      case TimePeriod.daily:
        return DateTime(date.year, date.month, date.day, 23, 59, 59);
      case TimePeriod.weekly:
        int daysFromMonday = date.weekday - 1;
        DateTime startOfWeek = date.subtract(Duration(days: daysFromMonday));
        DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
        return DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
      case TimePeriod.monthly:
        return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
      case TimePeriod.yearly:
        return DateTime(date.year, 12, 31, 23, 59, 59);
    }
  }

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.daily:
        return 'Daily';
      case TimePeriod.weekly:
        return 'Weekly';
      case TimePeriod.monthly:
        return 'Monthly';
      case TimePeriod.yearly:
        return 'Yearly';
    }
  }

  String _getPeriodTitle() {
    DateTime date = widget.selectedDate;
    switch (selectedPeriod) {
      case TimePeriod.daily:
        return DateFormat('dd MMM yyyy').format(date);
      case TimePeriod.weekly:
        DateTime startOfWeek = getStartDate(date, TimePeriod.weekly);
        DateTime endOfWeek = getEndDate(date, TimePeriod.weekly);
        DateTime endOfWeekDate = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);
        return '${DateFormat('dd MMM').format(startOfWeek)} - ${DateFormat('dd MMM yyyy').format(endOfWeekDate)}';
      case TimePeriod.monthly:
        return DateFormat('MMMM yyyy').format(date);
      case TimePeriod.yearly:
        return DateFormat('yyyy').format(date);
    }
  }

  Widget buildPeriodSelector(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<TimePeriod>(
        segments: TimePeriod.values.map((period) {
          return ButtonSegment<TimePeriod>(
            value: period,
            label: Text(_getPeriodLabel(period)),
          );
        }).toList(),
        selected: {selectedPeriod},
        onSelectionChanged: (Set<TimePeriod> newSelection) {
          setState(() {
            selectedPeriod = newSelection.first;
            _initializeStream();
          });
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget buildSummaryCards(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF2E7D32),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Income',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalIncome),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFEF5350),
                    Color(0xFFC62828),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFEF5350).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Expense',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalExpense),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChart(ColorScheme colorScheme) {
    if (expenseByCategory.isEmpty && incomeByCategory.isEmpty) {
      return SizedBox.shrink();
    }

    final List<Color> chartColors = [
      Color(0xFF2196F3),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFFE91E63),
      Color(0xFF00BCD4),
      Color(0xFF795548),
      Color(0xFF607D8B),
    ];

    List<PieChartSectionData> expenseSections = [];
    int colorIndex = 0;
    
    expenseByCategory.forEach((category, amount) {
      expenseSections.add(PieChartSectionData(
        value: amount.toDouble(),
        title: '',
        color: chartColors[colorIndex % chartColors.length],
        radius: 40,
      ));
      colorIndex++;
    });

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense by Category',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16),
          if (expenseSections.isNotEmpty)
            Row(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: PieChart(
                    PieChartData(
                      sections: expenseSections,
                      centerSpaceRadius: 30,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...expenseByCategory.entries.take(4).toList().asMap().entries.map((entry) {
                        int idx = entry.key;
                        var cat = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: chartColors[idx % chartColors.length],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cat.key,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(cat.value),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            )
          else
            Center(
              child: Text(
                'No expenses',
                style: GoogleFonts.poppins(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildTransactionCard(TransactionWithCategory transaction, ColorScheme colorScheme) {
    bool isIncome = transaction.category.type == 1;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: colorScheme.surfaceContainerLow,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) => TransactionPage(
                      transactionsWithCategory: transaction,
                    ),
                  ),
                )
                .then((updated) {
                  if (updated == true) {
                    refreshData();
                  }
                });
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isIncome
                        ? Color(0xFF4CAF50).withOpacity(0.15)
                        : Color(0xFFEF5350).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isIncome ? Color(0xFF4CAF50) : Color(0xFFEF5350),
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.category.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy • HH:mm').format(
                          transaction.transaction.transaction_date,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'} ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(transaction.transaction.amount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isIncome ? Color(0xFF4CAF50) : Color(0xFFEF5350),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () async {
                            await database.deleteTransactionRepo(
                              transaction.transaction.id,
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        refreshData();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildPeriodSelector(colorScheme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _getPeriodTitle(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            buildSummaryCards(colorScheme),
            StreamBuilder<List<TransactionWithCategory>>(
              stream: _transactionStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final data = snapshot.data;

                if (data != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    int income = 0;
                    int expense = 0;
                    Map<String, int> expByCat = {};
                    Map<String, int> incByCat = {};

                    for (var transaction in data) {
                      if (transaction.category.type == 1) {
                        income += transaction.transaction.amount;
                        incByCat[transaction.category.name] = 
                          (incByCat[transaction.category.name] ?? 0) + transaction.transaction.amount;
                      } else {
                        expense += transaction.transaction.amount;
                        expByCat[transaction.category.name] = 
                          (expByCat[transaction.category.name] ?? 0) + transaction.transaction.amount;
                      }
                    }

                    if (totalIncome != income || totalExpense != expense ||
                        expenseByCategory.toString() != expByCat.toString()) {
                      if (mounted) {
                        setState(() {
                          totalIncome = income;
                          totalExpense = expense;
                          expenseByCategory = expByCat;
                          incomeByCategory = incByCat;
                        });
                      }
                    }
                  });
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildChart(colorScheme),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        "Transactions",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (data != null && data.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return buildTransactionCard(data[index], colorScheme);
                        },
                      )
                    else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "No transactions yet",
                                style: GoogleFonts.poppins(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 80),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
