import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/utils/currency_input_formatter.dart';
import 'package:money_tracker/utils/page_transitions.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({Key? key}) : super(key: key);

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> with TickerProviderStateMixin {
  final AppDatabase database = AppDatabase();

  void _showAddEditDialog({Saving? saving}) {
    final colorScheme = Theme.of(context).colorScheme;
    final nameController = TextEditingController(text: saving?.name ?? '');
    final targetController = TextEditingController(
      text: saving != null ? CurrencyInputFormatter.formatFromInt(saving.targetAmount) : '',
    );
    final currentController = TextEditingController(
      text: saving != null ? CurrencyInputFormatter.formatFromInt(saving.currentAmount) : '',
    );
    DateTime? targetDate = saving?.targetDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.savings_rounded, color: Color(0xFF4CAF50), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                saving != null ? 'Edit Tabungan' : 'Tambah Tabungan',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Tabungan', style: GoogleFonts.poppins(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Dana Darurat',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Target Tabungan', style: GoogleFonts.poppins(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    hintText: '0',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Saldo Saat Ini', style: GoogleFonts.poppins(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: currentController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    hintText: '0',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Target Tanggal (Opsional)', style: GoogleFonts.poppins(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: targetDate ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() => targetDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Text(
                          targetDate != null ? DateFormat('dd MMM yyyy').format(targetDate!) : 'Pilih tanggal',
                          style: GoogleFonts.poppins(color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isEmpty || targetController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama dan target harus diisi')),
                  );
                  return;
                }

                final now = DateTime.now();
                final target = CurrencyInputFormatter.parseToInt(targetController.text);
                final current = CurrencyInputFormatter.parseToInt(currentController.text);

                if (saving == null) {
                  await database.insertSavingRepo(SavingsCompanion.insert(
                    name: nameController.text,
                    targetAmount: target,
                    currentAmount: Value(current),
                    targetDate: Value(targetDate),
                    createdAt: now,
                    updatedAt: now,
                  ));
                } else {
                  await database.updateSavingRepo(
                    saving.id,
                    name: nameController.text,
                    targetAmount: target,
                    currentAmount: current,
                    targetDate: targetDate,
                  );
                }

                Navigator.pop(context);
                setState(() {});
              },
              child: Text(saving != null ? 'Update' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMoneyDialog(Saving saving) {
    final colorScheme = Theme.of(context).colorScheme;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: Color(0xFF2196F3), size: 20),
            ),
            const SizedBox(width: 12),
            Text('Tambah Dana', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah dana ke "${saving.name}"',
              style: GoogleFonts.poppins(fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              final amount = CurrencyInputFormatter.parseToInt(amountController.text);
              if (amount > 0) {
                await database.addToSavingRepo(saving.id, amount);
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Saving saving) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Hapus Tabungan'),
        content: Text('Yakin ingin menghapus "${saving.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              await database.deleteSavingRepo(saving.id);
              Navigator.pop(context);
              setState(() {});
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingCard(Saving saving, int index, ColorScheme colorScheme) {
    final progress = saving.targetAmount > 0 
        ? (saving.currentAmount / saving.targetAmount).clamp(0.0, 1.0) 
        : 0.0;
    final percentage = (progress * 100).toStringAsFixed(1);
    final remaining = saving.targetAmount - saving.currentAmount;

    return AnimatedListItem(
      index: index,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Card(
          color: colorScheme.surfaceContainerLow,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showAddEditDialog(saving: saving),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(saving.color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.savings_rounded, color: Color(saving.color), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              saving.name,
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            if (saving.targetDate != null)
                              Text(
                                'Target: ${DateFormat('dd MMM yyyy').format(saving.targetDate!)}',
                                style: GoogleFonts.poppins(fontSize: 12, color: colorScheme.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _showAddMoneyDialog(saving),
                            icon: Icon(Icons.add_circle_outline_rounded, color: colorScheme.primary),
                            tooltip: 'Tambah Dana',
                          ),
                          IconButton(
                            onPressed: () => _showDeleteDialog(saving),
                            icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
                            tooltip: 'Hapus',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(saving.currentAmount),
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Color(saving.color)),
                      ),
                      Text(
                        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(saving.targetAmount),
                        style: GoogleFonts.poppins(fontSize: 14, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutQuint,
                    builder: (context, value, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 10,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(saving.color)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(saving.color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$percentage%',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Color(saving.color)),
                        ),
                      ),
                      Text(
                        remaining > 0 
                            ? 'Kurang ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(remaining)}'
                            : '🎉 Target Tercapai!',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: remaining > 0 ? colorScheme.onSurfaceVariant : const Color(0xFF4CAF50),
                          fontWeight: remaining > 0 ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: StreamBuilder<List<Saving>>(
        stream: database.watchAllSavingsRepo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final savings = snapshot.data ?? [];

          if (savings.isEmpty) {
            return Center(
              child: AnimatedAppearance(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.savings_outlined, size: 80, color: colorScheme.onSurfaceVariant.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada tabungan',
                      style: GoogleFonts.poppins(fontSize: 18, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mulai menabung untuk mencapai tujuanmu!',
                      style: GoogleFonts.poppins(fontSize: 14, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            );
          }

          // Calculate total savings
          final totalSaved = savings.fold<int>(0, (sum, s) => sum + s.currentAmount);
          final totalTarget = savings.fold<int>(0, (sum, s) => sum + s.targetAmount);

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Summary Card
                AnimatedAppearance(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.savings_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Total Tabungan',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalSaved),
                          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'dari target ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalTarget)}',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: totalTarget > 0 ? totalSaved / totalTarget : 0),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeOutQuint,
                            builder: (context, value, child) {
                              return LinearProgressIndicator(
                                value: value.clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Savings List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Daftar Tabungan',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${savings.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...savings.asMap().entries.map((entry) => _buildSavingCard(entry.value, entry.key, colorScheme)),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}
