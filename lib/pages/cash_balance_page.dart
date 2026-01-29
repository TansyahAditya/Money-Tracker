import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/utils/currency_input_formatter.dart';
import 'package:money_tracker/utils/page_transitions.dart';

class CashBalancePage extends StatefulWidget {
  const CashBalancePage({Key? key}) : super(key: key);

  @override
  State<CashBalancePage> createState() => _CashBalancePageState();
}

class _CashBalancePageState extends State<CashBalancePage> with TickerProviderStateMixin {
  final AppDatabase database = AppDatabase();

  void _showAddCashDialog({required bool isCashIn}) {
    final colorScheme = Theme.of(context).colorScheme;
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCashIn 
                    ? const Color(0xFF4CAF50).withOpacity(0.15)
                    : const Color(0xFFEF5350).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCashIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: isCashIn ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isCashIn ? 'Uang Masuk' : 'Uang Keluar',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jumlah', style: GoogleFonts.poppins(fontSize: 13, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              Text('Keterangan', style: GoogleFonts.poppins(fontSize: 13, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: isCashIn ? 'Contoh: Gaji bulanan' : 'Contoh: Belanja bulanan',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              final amount = CurrencyInputFormatter.parseToInt(amountController.text);
              final description = descriptionController.text.isEmpty 
                  ? (isCashIn ? 'Uang Masuk' : 'Uang Keluar')
                  : descriptionController.text;

              if (amount > 0) {
                if (isCashIn) {
                  await database.addCashInRepo(description, amount);
                } else {
                  await database.addCashOutRepo(description, amount);
                }
                Navigator.pop(context);
                setState(() {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Masukkan jumlah yang valid')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: isCashIn ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(CashBalanceEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Hapus Transaksi'),
        content: Text('Yakin ingin menghapus "${entry.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              await database.deleteCashBalanceRepo(entry.id);
              await database.recalculateCashBalancesRepo();
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

  Widget _buildTransactionCard(CashBalanceEntry entry, int index, ColorScheme colorScheme) {
    final isCashIn = entry.type == 1;

    return AnimatedListItem(
      index: index,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
          color: colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCashIn
                        ? const Color(0xFF4CAF50).withOpacity(0.15)
                        : const Color(0xFFEF5350).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCashIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isCashIn ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.description,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy • HH:mm').format(entry.transactionDate),
                        style: GoogleFonts.poppins(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isCashIn ? '+' : '-'} ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(entry.amount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCashIn ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Saldo: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(entry.balanceAfter)}',
                      style: GoogleFonts.poppins(fontSize: 11, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => _showDeleteDialog(entry),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline_rounded, size: 18, color: colorScheme.error),
                      ),
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'cash_out',
            onPressed: () => _showAddCashDialog(isCashIn: false),
            backgroundColor: const Color(0xFFEF5350),
            child: const Icon(Icons.remove_rounded, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'cash_in',
            onPressed: () => _showAddCashDialog(isCashIn: true),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Uang Masuk'),
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
          ),
        ],
      ),
      body: StreamBuilder<List<CashBalanceEntry>>(
        stream: database.watchAllCashBalanceRepo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data ?? [];

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Balance Summary Card
                StreamBuilder<int>(
                  stream: database.watchCurrentCashBalanceRepo(),
                  builder: (context, balanceSnapshot) {
                    final balance = balanceSnapshot.data ?? 0;
                    final isPositive = balance >= 0;

                    // Calculate totals
                    int totalIn = 0;
                    int totalOut = 0;
                    for (var entry in entries) {
                      if (entry.type == 1) {
                        totalIn += entry.amount;
                      } else {
                        totalOut += entry.amount;
                      }
                    }

                    return AnimatedAppearance(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPositive
                                ? [const Color(0xFF2196F3), const Color(0xFF1565C0)]
                                : [const Color(0xFFEF5350), const Color(0xFFC62828)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: (isPositive ? const Color(0xFF2196F3) : const Color(0xFFEF5350)).withOpacity(0.3),
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
                                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Saldo Saat Ini',
                                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: balance),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutQuint,
                              builder: (context, value, child) {
                                return Text(
                                  NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value),
                                  style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.arrow_downward_rounded, color: Colors.white70, size: 16),
                                            const SizedBox(width: 4),
                                            Text('Masuk', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalIn),
                                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.arrow_upward_rounded, color: Colors.white70, size: 16),
                                            const SizedBox(width: 4),
                                            Text('Keluar', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalOut),
                                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Transaction History
                if (entries.isEmpty)
                  AnimatedAppearance(
                    delay: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.4)),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada transaksi',
                            style: GoogleFonts.poppins(fontSize: 16, color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulai catat uang masuk dan keluar',
                            style: GoogleFonts.poppins(fontSize: 14, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          'Riwayat Transaksi',
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
                            '${entries.length}',
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
                  ...entries.asMap().entries.map((e) => _buildTransactionCard(e.value, e.key, colorScheme)),
                ],
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }
}
