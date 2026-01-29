import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/models/transaction_with_category.dart';
import 'package:money_tracker/utils/currency_input_formatter.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionsWithCategory;
  const TransactionPage({Key? key, required this.transactionsWithCategory})
      : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> with SingleTickerProviderStateMixin {
  bool isExpense = true;
  late int type;
  final AppDatabase database = AppDatabase();
  Category? selectedCategory;
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Animation controller for smooth transitions
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuint,
    );
    _animController.forward();

    if (widget.transactionsWithCategory != null) {
      updateTransaction(widget.transactionsWithCategory!);
    } else {
      type = 2;
      dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      timeController.text = DateFormat('HH:mm').format(DateTime.now());
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  void updateTransaction(TransactionWithCategory initTransaction) {
    // Format the amount with currency formatter for display
    amountController.text = CurrencyInputFormatter.formatFromInt(initTransaction.transaction.amount);
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
          isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Toggle with smooth animation
                Container(
                  padding: const EdgeInsets.all(4),
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
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutQuint,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: !isExpense
                                  ? const Color(0xFF4CAF50)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: !isExpense ? [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
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
                                const SizedBox(width: 8),
                                Text(
                                  'Pemasukan',
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
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutQuint,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isExpense
                                  ? const Color(0xFFEF5350)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isExpense ? [
                                BoxShadow(
                                  color: const Color(0xFFEF5350).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
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
                                const SizedBox(width: 8),
                                Text(
                                  'Pengeluaran',
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
                const SizedBox(height: 32),

                // Amount Field with auto-formatting
                Text(
                  'Jumlah',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: isExpense ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
                  ),
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    prefixStyle: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    hintText: '0',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 24),

                // Category
                Text(
                  'Kategori',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Category>>(
                  future: getAllCategory(type),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        selectedCategory ??= snapshot.data!.first;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<Category>(
                            isExpanded: true,
                            value: selectedCategory,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
                          padding: const EdgeInsets.all(16),
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
                              const SizedBox(width: 12),
                              Text(
                                'Tambahkan kategori terlebih dahulu',
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
                const SizedBox(height: 24),

                // Date & Time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: dateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.calendar_today_rounded),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Waktu',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: timeController,
                            readOnly: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.access_time_rounded),
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
                const SizedBox(height: 24),

                // Description
                Text(
                  'Keterangan (Opsional)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan...',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 40),

                // Save Button with animation
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () async {
                      // Parse the formatted amount back to integer
                      final amount = CurrencyInputFormatter.parseToInt(amountController.text);
                      
                      if (amount == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Masukkan jumlah yang valid')),
                        );
                        return;
                      }
                      if (selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
                        );
                        return;
                      }

                      final description = descriptionController.text;
                      final dateStr = dateController.text;
                      final timeStr = timeController.text;
                      
                      if (dateStr.isEmpty || timeStr.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tanggal dan waktu tidak boleh kosong')),
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
                      backgroundColor: isExpense ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Update Transaksi' : 'Simpan Transaksi',
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
      ),
    );
  }
}