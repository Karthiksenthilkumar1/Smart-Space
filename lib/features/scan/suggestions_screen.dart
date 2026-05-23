import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  bool isLoading = true;
  String roomType = "";
  List recommendations = [];

  final Map<String, String> productIds = {
    "Compact Study Table": "cmpi0vop90002xmgmn7msd4rt",
    "Compact Chair": "cmpi0sbcy0000xmgm6bqn75jd",
    "Corner Lamp": "cmpi0u26f0001xmgm9fdyuan7",
    "Bedside Table": "cmpi0vop90002xmgmn7msd4rt",
    "Compact Wardrobe": "cmpi0u26f0001xmgm9fdyuan7",
    "Wall Shelf": "cmpi0sbcy0000xmgm6bqn75jd",
    "Kitchen Storage Rack": "cmpi0vop90002xmgmn7msd4rt",
    "Compact Utility Shelf": "cmpi0u26f0001xmgm9fdyuan7",
    "Wall Mounted Organizer": "cmpi0sbcy0000xmgm6bqn75jd",
  };

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final response = await ApiService.getRecommendations();

    if (response["statusCode"] == 200) {
      setState(() {
        roomType = response["data"]["roomType"];
        recommendations = response["data"]["recommendations"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          "AI Suggestions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 32),
                const SizedBox(height: 14),
                Text(
                  "$roomType Detected",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Products are recommended based on detected room type and available space.",
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          ...recommendations.map(
            (product) => Container(
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
                    height: 76,
                    width: 76,
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product["name"],
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            IconButton(
                              onPressed: () async {
                                final productId =
                                    productIds[
                                        product["name"]];

                                if (productId == null) {
                                  return;
                                }

                                final response =
                                    await ApiService
                                        .saveProduct(
                                  productId: productId,
                                );

                                if (response[
                                        "statusCode"] ==
                                    201) {
                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Product saved successfully",
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        response["data"]
                                                [
                                                "message"] ??
                                            "Failed to save product",
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.bookmark_border,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          product["size"],
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            _badge(
                              product["fit"],
                              Colors.green,
                            ),
                            const SizedBox(width: 8),
                            _badge(
                              "${product["match"]} Match",
                              Colors.indigo,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _badge(
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}