import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool isLoading = true;
  List categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final response = await ApiService.getCategories();

    if (response["statusCode"] == 200) {
      setState(() {
        categories = response["data"]["categories"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  IconData _getCategoryIcon(String category) {
    final name = category.toLowerCase();

    if (name.contains("kitchen")) return Icons.kitchen;
    if (name.contains("study")) return Icons.menu_book;
    if (name.contains("bed")) return Icons.bed;
    if (name.contains("storage")) return Icons.inventory_2;
    if (name.contains("decor")) return Icons.lightbulb_outline;
    return Icons.category;
  }

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();

    final categoryName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter category name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, controller.text.trim());
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (categoryName != null && categoryName.isNotEmpty) {
      final response = await ApiService.createCategory(
        category: categoryName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["data"]["message"] ?? "Category added",
          ),
        ),
      );

      _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Categories"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Category"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (categories.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        "No categories found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                ...categories.map((category) {
                  final categoryName =
                    category["name"] ?? "Uncategorized";

                  return GestureDetector(
                    onTap: () async {
                      final refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryDetailScreen(
                            category: category,
                          ),
                        ),
                      );

                      if (refresh == true) {
                        _loadCategories();
                      }
                    },
                    child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 65,
                          width: 65,
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _getCategoryIcon(categoryName),
                            color: Colors.indigo,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoryName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "${category["productCount"]} products",
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Category"),
                                content: Text(
                                  "Delete ${categoryName} category?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final response = await ApiService.deleteCategory(
                                categoryId: category["id"],
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response["data"]["message"] ??
                                        "Category delete failed",
                                  ),
                                ),
                              );

                              _loadCategories();
                            }
                          },
                        ),
                      ],
                    ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}