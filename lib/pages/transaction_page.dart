import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/models/transaction_with_category.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionsWithCategory;
  const TransactionPage({Key? key, required this.transactionsWithCategory})
      : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool isExpense = true;
  late int type;
  final AppDatabase database = AppDatabase();
  Category? selectedCategory;
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    if (widget.transactionsWithCategory != null) {
      updateTransaction(widget.transactionsWithCategory!);
    } else {
      type = 2;
      dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      timeController.text = DateFormat('HH:mm').format(DateTime.now());
    }
    super.initState();
  }

  void updateTransaction(TransactionWithCategory initTransaction) {
    amountController.text = initTransaction.transaction.amount.toString();
    descriptionController.text = initTransaction.transaction.description;
    dateController.text = DateFormat('yyyy-MM-dd').format(initTransaction.transaction.transaction_date);
    timeController.text = DateFormat('HH:mm').format(initTransaction.transaction.transaction_date);
    type = initTransaction.category.type;
    isExpense = (type == 2);
    selectedCategory = initTransaction.category;
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.transactionsWithCategory != null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        title: Text(
          isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Toggle
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpense = false;
                            type = 1;
                            selectedCategory = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isExpense
                                ? Color(0xFF4CAF50)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_downward_rounded,
                                size: 18,
                                color: !isExpense
                                    ? Colors.white
                                    : colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Income',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: !isExpense
                                      ? Colors.white
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpense = true;
                            type = 2;
                            selectedCategory = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isExpense
                                ? Color(0xFFEF5350)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_upward_rounded,
                                size: 18,
                                color: isExpense
                                    ? Colors.white
                                    : colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Expense',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: isExpense
                                      ? Colors.white
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Amount Field
              Text(
                'Amount',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  hintText: '0',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              SizedBox(height: 24),

              // Category
              Text(
                'Category',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 8),
              FutureBuilder<List<Category>>(
                future: getAllCategory(type),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      selectedCategory ??= snapshot.data!.first;
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<Category>(
                          isExpanded: true,
                          value: selectedCategory,
                          underline: SizedBox(),
                          icon: Icon(Icons.keyboard_arrow_down_rounded),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                          onChanged: (Category? newValue) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          },
                          items: snapshot.data!.map((Category value) {
                            return DropdownMenuItem<Category>(
                              value: value,
                              child: Text(value.name),
                            );
                          }).toList(),
                        ),
                      );
                    } else {
                      return Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: colorScheme.onErrorContainer,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Add a category first',
                              style: GoogleFonts.poppins(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
              ),
              SizedBox(height: 24),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today_rounded),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: timeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.access_time_rounded),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                          onTap: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                timeController.text = DateFormat('HH:mm').format(
                                  DateTime(2025, 1, 1, pickedTime.hour, pickedTime.minute),
                                );
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Description
              Text(
                'Description (Optional)',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add a note...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () async {
                    if (amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter an amount')),
                      );
                      return;
                    }
                    if (selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a category')),
                      );
                      return;
                    }

                    final description = descriptionController.text;
                    final amount = int.parse(amountController.text);
                    final dateStr = dateController.text;
                    final timeStr = timeController.text;
                    
                    if (dateStr.isEmpty || timeStr.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Date and time cannot be empty')),
                      );
                      return;
                    }
                    
                    final dateTimeStr = '$dateStr $timeStr:00';
                    final date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeStr);
                    final categoryId = selectedCategory!.id;
                    final now = DateTime.now();

                    if (widget.transactionsWithCategory == null) {
                      await database.into(database.transactions).insertReturning(
                        TransactionsCompanion.insert(
                          description: description,
                          category_id: categoryId,
                          amount: amount,
                          transaction_date: date,
                          created_at: now,
                          updated_at: now,
                        ),
                      );
                    } else {
                      await database.updateTransactionRepo(
                        widget.transactionsWithCategory!.transaction.id,
                        description,
                        categoryId,
                        amount,
                        date,
                        now,
                      );
                    }
                    Navigator.pop(context, true);
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Update Transaction' : 'Save Transaction',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}