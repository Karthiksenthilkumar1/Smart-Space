import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class SuggestionsScreen extends StatefulWidget {
  final double width;
  final double height;
  final double depth;
  final double area;

  const SuggestionsScreen({
    super.key,
    required this.width,
    required this.height,
    required this.depth,
    required this.area,
  });

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
    "Corner Lamp": "cmpi0u26f0001xmgmn7msd4rt",
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
    final response = await ApiService.getRecommendations(
      width: widget.width,
      height: widget.height,
      depth: widget.depth,
      area: widget.area,
    );

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
        title: const Text("AI Suggestions"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "$roomType Detected",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          ...recommendations.map((product) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2, color: Colors.indigo, size: 34),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      product["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () async {
                      final productId = productIds[product["name"]];
                      if (productId == null) return;

                      await ApiService.saveProduct(productId: productId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Product saved")),
                      );
                    },
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