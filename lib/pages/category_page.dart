import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tracker/models/database.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpense = true;
  int type = 2;
  final AppDatabase database = AppDatabase();
  TextEditingController categoryNameController = TextEditingController();

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  Future insert(String name, int type) async {
    DateTime now = DateTime.now();
    await database.into(database.categories).insertReturning(
      CategoriesCompanion.insert(
        name: name,
        type: type,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future update(int categoryId, String newName) async {
    await database.updateCategoryRepo(categoryId, newName);
  }

  void openDialog(Category? category) {
    final colorScheme = Theme.of(context).colorScheme;
    categoryNameController.clear();
    if (category != null) {
      categoryNameController.text = category.name;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isExpense
                      ? Color(0xFFEF5350).withOpacity(0.15)
                      : Color(0xFF4CAF50).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: isExpense ? Color(0xFFEF5350) : Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                category != null ? 'Edit Category' : 'New Category',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isExpense ? 'Expense Category' : 'Income Category',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: categoryNameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Category name',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (categoryNameController.text.isNotEmpty) {
                  if (category == null) {
                    insert(categoryNameController.text, isExpense ? 2 : 1);
                  } else {
                    update(category.id, categoryNameController.text);
                  }
                  setState(() {});
                  Navigator.pop(context);
                }
              },
              child: Text(category != null ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Type Toggle
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
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
          ),

          // Add Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: () => openDialog(null),
                  icon: Icon(Icons.add_rounded, size: 18),
                  label: Text('Add Category'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Category List
          FutureBuilder<List<Category>>(
            future: getAllCategory(type),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final category = snapshot.data![index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Card(
                          color: colorScheme.surfaceContainerLow,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isExpense
                                    ? Color(0xFFEF5350).withOpacity(0.15)
                                    : Color(0xFF4CAF50).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isExpense
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                color: isExpense
                                    ? Color(0xFFEF5350)
                                    : Color(0xFF4CAF50),
                              ),
                            ),
                            title: Text(
                              category.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => openDialog(category),
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(28),
                                        ),
                                        title: Text('Delete Category'),
                                        content: Text(
                                          'Are you sure you want to delete "${category.name}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('Cancel'),
                                          ),
                                          FilledButton(
                                            onPressed: () {
                                              database.deleteCategoryRepo(category.id);
                                              setState(() {});
                                              Navigator.pop(context);
                                            },
                                            style: FilledButton.styleFrom(
                                              backgroundColor: colorScheme.error,
                                            ),
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No categories yet',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first ${isExpense ? 'expense' : 'income'} category',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
