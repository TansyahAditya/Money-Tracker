import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/pages/category_page.dart';
import 'package:money_tracker/pages/home_page.dart';
import 'package:money_tracker/pages/savings_page.dart';
import 'package:money_tracker/pages/cash_balance_page.dart';
import 'package:money_tracker/pages/transaction_page.dart';
import 'package:money_tracker/utils/page_transitions.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex;

  final database = AppDatabase();

  TextEditingController categoryNameController = TextEditingController();

  // Animation controller for page transitions
  late AnimationController _pageAnimController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller FIRST
    _pageAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _pageAnimController,
      curve: Curves.easeOutQuint,
    );
    
    // Now initialize view
    selectedDate = DateTime.now();
    currentIndex = 0;
    _initChildren();
    _pageAnimController.forward();
  }
  
  void _initChildren() {
    _children = [
      HomePage(
        key: ValueKey('${selectedDate.toString()}_$currentIndex'),
        selectedDate: selectedDate,
      ),
      const CategoryPage(),
      const SavingsPage(),
      const CashBalancePage(),
    ];
  }

  @override
  void dispose() {
    _pageAnimController.dispose();
    categoryNameController.dispose();
    super.dispose();
  }

  Future<List<Category>> getAllCategory() {
    return database.select(database.categories).get();
  }

  void updateView(int index, DateTime? date) {
    // Animate page transition
    _pageAnimController.reset();
    _pageAnimController.forward();
    
    setState(() {
      if (date != null) {
        selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }
      currentIndex = index;
      _children = [
        HomePage(
          key: ValueKey('${selectedDate.toString()}_$currentIndex'),
          selectedDate: selectedDate,
        ),
        const CategoryPage(),
        const SavingsPage(),
        const CashBalancePage(),
      ];
    });
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Kategori';
      case 2:
        return 'Tabungan';
      case 3:
        return 'Saldo Kas';
      default:
        return '';
    }
  }

  String _getPageSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Ringkasan keuanganmu';
      case 1:
        return 'Kelola kategorimu';
      case 2:
        return 'Capai target tabunganmu';
      case 3:
        return 'Lacak uang masuk & keluar';
      default:
        return '';
    }
  }

  IconData _getPageIcon(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard_rounded;
      case 1:
        return Icons.category_rounded;
      case 2:
        return Icons.savings_rounded;
      case 3:
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: Visibility(
        visible: currentIndex == 0,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context)
                .push(
                  SmoothPageRoute(
                    page: const TransactionPage(transactionsWithCategory: null),
                  ),
                )
                .then((value) {
                  if (value == true) {
                    updateView(0, selectedDate);
                  }
                });
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah'),
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          updateView(index, selectedDate);
        },
        animationDuration: const Duration(milliseconds: 400),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category_rounded),
            label: 'Kategori',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings_rounded),
            label: 'Tabungan',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Saldo',
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom App Bar for non-dashboard pages
          if (currentIndex != 0)
            SafeArea(
              bottom: false,
              child: AnimatedAppearance(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getPageIcon(currentIndex),
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPageTitle(currentIndex),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            _getPageSubtitle(currentIndex),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (currentIndex == 0)
            CalendarAppBar(
              fullCalendar: true,
              backButton: false,
              accent: colorScheme.primary,
              locale: 'id',
              onDateChanged: (value) {
                setState(() {
                  selectedDate = value;
                  updateView(0, selectedDate);
                });
              },
              lastDate: DateTime.now(),
            ),
          // Content with fade animation
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _children[currentIndex],
            ),
          ),
        ],
      ),
    );
  }
}
