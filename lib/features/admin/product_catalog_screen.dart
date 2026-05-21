import 'package:flutter/material.dart';

class ProductCatalogScreen extends StatelessWidget {
  const ProductCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        "name": "Compact Study Table",
        "category": "Furniture",
        "size": "110 × 55 × 75 cm",
        "price": "₹4,999",
      },
      {
        "name": "Modern Sofa",
        "category": "Living Room",
        "size": "180 × 85 × 90 cm",
        "price": "₹18,999",
      },
      {
        "name": "Kitchen Rack",
        "category": "Kitchen",
        "size": "90 × 35 × 120 cm",
        "price": "₹3,499",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Product Catalog"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search products",
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

          ...products.map(
            (product) => Container(
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
                    child: const Icon(Icons.inventory_2, color: Colors.indigo),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product["name"]!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text(product["category"]!,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 5),
                        Text("${product["size"]} • ${product["price"]}",
                            style: const TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}