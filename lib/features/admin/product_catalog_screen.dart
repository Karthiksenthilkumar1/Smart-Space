import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  bool isLoading = true;

  List products = [];
  List filteredProducts = [];

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await ApiService.getProducts();

    if (response["statusCode"] == 200) {
      setState(() {
        products = response["data"]["products"];
        filteredProducts = products;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      searchQuery = query;

      filteredProducts = products.where((product) {
        final name = product["name"].toString().toLowerCase();

        final category = product["category"].toString().toLowerCase();

        return name.contains(query.toLowerCase()) ||
            category.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _deleteProduct(String productId) async {
    final response = await ApiService.deleteProduct(
      productId: productId,
    );

    if (response["statusCode"] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Product deleted successfully",
          ),
        ),
      );

      _loadProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["data"]["message"] ?? "Failed to delete product",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Product Catalog"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddProductScreen(),
                ),
              );

              if (refresh == true) {
                _loadProducts();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 250),
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      0,
                    ),
                    child: TextField(
                      onChanged: _filterProducts,
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];

                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 14,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              18,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                                child: product["imageUrl"] != null &&
                                        product["imageUrl"]
                                            .toString()
                                            .trim()
                                            .startsWith(
                                              "http",
                                            )
                                    ? Image.network(
                                        product["imageUrl"].toString(),
                                        height: 56,
                                        width: 56,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: 56,
                                        width: 56,
                                        color: Colors.indigo.shade50,
                                        child: const Icon(
                                          Icons.inventory_2,
                                          color: Colors.indigo,
                                          size: 30,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product["name"] ?? "Product",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      product["dimensions"] ?? "No dimensions",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "₹${product["price"]}",
                                      style: const TextStyle(
                                        color: Colors.indigo,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.indigo,
                                ),
                                onPressed: () async {
                                  final refresh = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProductScreen(
                                        product: product,
                                      ),
                                    ),
                                  );

                                  if (refresh == true) {
                                    _loadProducts();
                                  }
                                },
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
                                      title: const Text(
                                        "Delete Product",
                                      ),
                                      content: Text(
                                        "Are you sure you want to delete ${product["name"]}?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            context,
                                            false,
                                          ),
                                          child: const Text(
                                            "Cancel",
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            context,
                                            true,
                                          ),
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    _deleteProduct(
                                      product["id"],
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
