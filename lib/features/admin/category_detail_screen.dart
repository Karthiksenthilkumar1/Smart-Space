import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';
import 'product_catalog_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Map category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState
    extends State<CategoryDetailScreen> {
  bool isLoading = true;

  List products = [];

  late TextEditingController categoryController;

  @override
  void initState() {
    super.initState();

    categoryController = TextEditingController(
      text: widget.category["name"],
    );

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response =
        await ApiService.getCategoryProducts(
      categoryId: widget.category["id"],
    );

    if (response["statusCode"] == 200) {
      setState(() {
        products = response["data"]["products"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateCategory() async {
    final response =
        await ApiService.updateCategory(
      categoryId: widget.category["id"],
      name: categoryController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response["data"]["message"] ??
              "Category updated",
        ),
      ),
    );

    if (response["statusCode"] == 200) {
      Navigator.pop(context, true);
    }
  }

  Widget _productImage(String? imageUrl) {
    if (imageUrl != null &&
        imageUrl.startsWith("http")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imageUrl,
          height: 62,
          width: 62,
          fit: BoxFit.cover,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return _fallbackImage();
          },
        ),
      );
    }

    return _fallbackImage();
  }

  Widget _fallbackImage() {
    return Container(
      height: 62,
      width: 62,
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.inventory_2,
        color: Colors.indigo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Category Details"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: "Category Name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _updateCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                    ),
                    child: const Text(
                      "UPDATE CATEGORY",
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  "Products (${products.length})",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                if (products.isEmpty)
                  const Text(
                    "No products found",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                ...products.map((product) {
                  return Container(
                    margin:
                        const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        _productImage(
                          product["imageUrl"],
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                product["name"] ??
                                    "Product",
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                product["dimensions"] ??
                                    "",
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                "₹${product["price"] ?? 0}",
                                style: const TextStyle(
                                  color: Colors.indigo,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == "manage") {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProductCatalogScreen(),
                                ),
                              );

                              _loadProducts();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: "manage",
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.indigo),
                                  SizedBox(width: 10),
                                  Text("Edit/Delete"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}