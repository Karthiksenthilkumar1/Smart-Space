import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = product["imageUrl"];
    final name = product["name"] ?? "Product";
    final description = product["description"] ?? "No description available";
    final size = product["size"] ?? "Dimensions unavailable";
    final category = product["category"] ?? "Category";
    final price = product["price"];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Product Details"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: imageUrl != null && imageUrl.toString().startsWith("http")
                ? Image.network(
                    imageUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 260,
                    color: Colors.indigo.shade50,
                    child: const Icon(
                      Icons.inventory_2,
                      size: 90,
                      color: Colors.indigo,
                    ),
                  ),
          ),

          const SizedBox(height: 22),

          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            category,
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          if (price != null)
            Text(
              "₹$price",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

          const SizedBox(height: 20),

          _infoCard(
            icon: Icons.straighten,
            title: "Dimensions",
            value: size,
          ),

          _infoCard(
            icon: Icons.description_outlined,
            title: "Description",
            value: description,
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () async {
                final response = await ApiService.saveProduct(
                  productId: product["id"],
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      response["data"]["message"] ?? "Product saved",
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.bookmark_border),
              label: const Text("SAVE PRODUCT"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(color: Colors.grey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}