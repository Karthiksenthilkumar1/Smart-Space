import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';
import '../../scan/product_detail_screen.dart';
import 'package:smart_space/core/services/api_service.dart';

class VideoSuggestionsScreen extends StatefulWidget {
  final List measurements;
  final String roomType;

  const VideoSuggestionsScreen({
    super.key,
    required this.measurements,
    required this.roomType,
  });

  @override
  State<VideoSuggestionsScreen> createState() =>
      _VideoSuggestionsScreenState();
}

class _VideoSuggestionsScreenState
    extends State<VideoSuggestionsScreen> {
  bool isLoading = true;

  List recommendationGroups = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    for (var measurement in widget.measurements) {
        if (measurement["measurementType"] != "OBJECT_3D") {
            continue;
        }
        
        double width;
        double height;
        double depth;
        double area;


        if (measurement["measurementType"] == "OBJECT_3D") {
        width = (measurement["width"] as num).toDouble();
        height = (measurement["height"] as num).toDouble();
        depth = (measurement["depth"] as num).toDouble();
        area = (measurement["area"] as num).toDouble();
        } else {
        final distance =
            (measurement["distance"] as num).toDouble();

        width = distance;
        height = distance;
        depth = distance;
        area = distance;
        }

        final response =
            await ApiService.getRecommendations(
        width: width,
        height: height,
        depth: depth,
        area: area,
        roomType: widget.roomType,
        );

        if (response["statusCode"] == 200) {
        recommendationGroups.add({
            "measurement": measurement,
            "products":
                response["data"]["recommendations"] ??
                    [],
        });
        }
    }

    setState(() {
        isLoading = false;
    });
    }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Video Recommendations",
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount:
            recommendationGroups.length,
        itemBuilder: (context, index) {
          final group =
              recommendationGroups[index];

          final measurement =
              group["measurement"];

          final products =
              group["products"] as List;

          return Container(
            margin:
                const EdgeInsets.only(
              bottom: 20,
            ),
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  measurement["name"],
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                    measurement["measurementType"] == "OBJECT_3D"
                        ? "W:${(measurement["width"] as num).toDouble().toStringAsFixed(1)}  H:${(measurement["height"] as num).toDouble().toStringAsFixed(1)}  D:${(measurement["depth"] as num).toDouble().toStringAsFixed(1)}"
                        : "${(measurement["distance"] as num).toDouble().toStringAsFixed(1)} cm",
                  style:
                      const TextStyle(
                    color: Colors.indigo,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const Divider(height: 25),

                if (products.isEmpty)
                Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                    children: [
                        Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 50,
                        ),
                        SizedBox(height: 12),
                        Text(
                        "No Products Fit This Measurement",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                        ),
                        ),
                        SizedBox(height: 8),
                        Text(
                        "The available space is too small for products in the catalog.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey,
                        ),
                        ),
                    ],
                    ),
                ),

                if (products.isNotEmpty)
                ...products.take(5).map(
                  (product) {
                    return Card(
                    margin: const EdgeInsets.only(
                        bottom: 10,
                    ),
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                            ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: product["imageUrl"] != null &&
                                    product["imageUrl"]
                                        .toString()
                                        .startsWith("http")
                                ? Image.network(
                                    product["imageUrl"],
                                    height: 76,
                                    width: 76,
                                    fit: BoxFit.cover,
                                    )
                                : Container(
                                    height: 76,
                                    width: 76,
                                    decoration: BoxDecoration(
                                        color: Colors.indigo.shade50,
                                        borderRadius:
                                            BorderRadius.circular(18),
                                    ),
                                    child: const Icon(
                                        Icons.chair_outlined,
                                        color: Colors.indigo,
                                    ),
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
                                            product["name"] ??
                                                "Product",
                                            style:
                                                const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 16,
                                            ),
                                        ),
                                        ),

                                        IconButton(
                                        icon: const Icon(
                                            Icons.bookmark_border,
                                        ),
                                        onPressed: () async {

                                            if (product["id"] ==
                                                null) {
                                            return;
                                            }

                                            final response =
                                                await ApiService
                                                    .saveProduct(
                                            productId:
                                                product["id"],
                                            );

                                            if (!mounted) return;

                                            ScaffoldMessenger.of(
                                                    context)
                                                .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                response["data"]
                                                        [
                                                        "message"] ??
                                                    "Product Saved",
                                                ),
                                            ),
                                            );
                                        },
                                        ),
                                    ],
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                    product["size"] ??
                                        "Dimensions unavailable",
                                    style: const TextStyle(
                                        color: Colors.grey,
                                    ),
                                    ),

                                    const SizedBox(height: 8),

                                    if (product["price"] != null)
                                    Text(
                                        "₹${product["price"]}",
                                        style: const TextStyle(
                                        color: Colors.indigo,
                                        fontWeight:
                                            FontWeight.bold,
                                        ),
                                    ),

                                    const SizedBox(height: 10),

                                    Wrap(
                                    spacing: 8,
                                    children: [

                                        Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                            color: Colors.green
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                        ),
                                        child: Text(
                                            product["fit"] ?? "",
                                            style:
                                                const TextStyle(
                                            color: Colors.green,
                                            fontWeight:
                                                FontWeight.bold,
                                            ),
                                        ),
                                        ),

                                        Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                            color: Colors.indigo
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                        ),
                                        child: Text(
                                            "${product["match"]}",
                                            style:
                                                const TextStyle(
                                            color: Colors.indigo,
                                            fontWeight:
                                                FontWeight.bold,
                                            ),
                                        ),
                                        ),
                                    ],
                                    ),

                                    const SizedBox(height: 10),

                                    Container(
                                    padding:
                                        const EdgeInsets.all(12),
                                    decoration:
                                        BoxDecoration(
                                        color:
                                            Colors.indigo.shade50,
                                        borderRadius:
                                            BorderRadius.circular(
                                                14),
                                    ),
                                    child: Text(
                                        product["reason"] ?? "",
                                        style:
                                            const TextStyle(
                                        color:
                                            Colors.indigo,
                                        ),
                                    ),
                                    ),
                                    const SizedBox(height: 10),

                                    if (product["reasonPoints"] != null)
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: List.generate(
                                        product["reasonPoints"].length,
                                        (index) {
                                            return Padding(
                                            padding:
                                                const EdgeInsets.only(
                                                bottom: 6,
                                            ),
                                            child: Row(
                                                children: [
                                                const Icon(
                                                    Icons.check_circle,
                                                    size: 16,
                                                    color: Colors.green,
                                                ),

                                                const SizedBox(width: 6),

                                                Expanded(
                                                    child: Text(
                                                    product["reasonPoints"][index],
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black87,
                                                    ),
                                                    ),
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
                            ],
                        ),
                        ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}