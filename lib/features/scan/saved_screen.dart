import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  bool isLoading = true;
  List savedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadSavedProducts();
  }

  Future<void> _loadSavedProducts() async {
    final response = await ApiService.getSavedProducts();

    if (response["statusCode"] == 200) {
      setState(() {
        savedProducts = response["data"]["savedProducts"];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          "Saved Products",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedProducts.isEmpty
              ? const Center(child: Text("No saved products yet"))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      "Your bookmarked recommendations",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    ...savedProducts.map((item) {
                      final product = item["product"];

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
                            Container(
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
                                    product["dimensions"] ?? "No dimensions",
                                    style: const TextStyle(color: Colors.grey),
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
                                onPressed: () async {
                                    final response =
                                        await ApiService.removeSavedProduct(
                                    savedProductId: item["id"],
                                    );

                                    if (response["statusCode"] == 200) {
                                    setState(() {
                                        savedProducts.remove(item);
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                        content: Text("Removed from saved products"),
                                        ),
                                    );
                                    }
                                },
                                icon: const Icon(
                                    Icons.bookmark,
                                    color: Colors.indigo,
                                ),
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