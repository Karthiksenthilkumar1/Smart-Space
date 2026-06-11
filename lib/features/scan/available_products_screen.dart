import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class AvailableProductsScreen extends StatefulWidget {
  const AvailableProductsScreen({super.key});

  @override
  State<AvailableProductsScreen> createState() =>
      _AvailableProductsScreenState();
}

class _AvailableProductsScreenState extends State<AvailableProductsScreen> {
  bool isLoading = true;
  List products = [];
  List filteredProducts = [];

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
      filteredProducts = products.where((product) {
        final name = product["name"].toString().toLowerCase();
        final category = product["category"].toString().toLowerCase();

        return name.contains(query.toLowerCase()) ||
            category.contains(query.toLowerCase());
      }).toList();
    });
  }

  Widget _fallbackImage() {
    return Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(
        Icons.inventory_2,
        color: Colors.indigo,
        size: 34,
      ),
    );
  }

  Future<void> _saveProduct(dynamic product) async {
    final response = await ApiService.saveProduct(
      productId: product["id"],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response["statusCode"] == 201
              ? "Product saved"
              : response["data"]["message"] ?? "Save failed",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          "Available Products",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 250),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  TextField(
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
                  const SizedBox(height: 20),
                  if (filteredProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(
                        child: Text(
                          "No products available",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ...filteredProducts.map((product) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: product["imageUrl"] != null &&
                                    product["imageUrl"]
                                        .toString()
                                        .startsWith("http")
                                ? Image.network(
                                    product["imageUrl"],
                                    height: 72,
                                    width: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _fallbackImage();
                                    },
                                  )
                                : _fallbackImage(),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product["name"] ?? "Product",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  product["category"] ?? "Category",
                                  style: const TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  product["dimensions"] ?? "No dimensions",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "₹${product["price"] ?? 0}",
                                  style: const TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _saveProduct(product);
                            },
                            icon: const Icon(
                              Icons.bookmark_border,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
