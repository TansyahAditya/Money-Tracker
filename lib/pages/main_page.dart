import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/pages/category_page.dart';
import 'package:money_tracker/pages/home_page.dart';
import 'package:money_tracker/pages/transaction_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex;

  final database = AppDatabase();

  TextEditingController categoryNameController = TextEditingController();

  @override
  void initState() {
    selectedDate = DateTime.now();
    currentIndex = 0;
    updateView(0, selectedDate);
    super.initState();
  }

  Future<List<Category>> getAllCategory() {
    return database.select(database.categories).get();
  }

  void updateView(int index, DateTime? date) {
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
        CategoryPage(),
      ];
    });
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
                  MaterialPageRoute(
                    builder: (context) =>
                        TransactionPage(transactionsWithCategory: null),
                  ),
                )
                .then((value) {
                  if (value == true) {
                    updateView(0, selectedDate);
                  }
                });
          },
          icon: Icon(Icons.add_rounded),
          label: Text('Add'),
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          updateView(index, selectedDate);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category_rounded),
            label: 'Categories',
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom App Bar
          if (currentIndex == 1)
            SafeArea(
              bottom: false,
              child: Container(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.category_rounded,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categories',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Manage your categories',
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
          if (currentIndex == 0)
            CalendarAppBar(
              fullCalendar: true,
              backButton: false,
              accent: colorScheme.primary,
              locale: 'en',
              onDateChanged: (value) {
                setState(() {
                  selectedDate = value;
                  updateView(0, selectedDate);
                });
              },
              lastDate: DateTime.now(),
            ),
          // Content
          Expanded(child: _children[currentIndex]),
        ],
      ),
    );
  }
}
