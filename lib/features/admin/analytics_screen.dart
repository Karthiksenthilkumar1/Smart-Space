import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';
import '../../core/widgets/gradient_header_card.dart';
import '../../core/widgets/activity_tile.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool isLoading = true;

  Map analytics = {
    "users": 0,
    "scans": 0,
    "imageScans": 0,
    "videoScans": 0,
    "products": 0,
    "savedProducts": 0,
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final response = await ApiService.getAnalytics();

    if (response["statusCode"] == 200) {
      setState(() {
        analytics = response["data"]["analytics"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final analyticsCards = [
      {
        "title": "Total Scans",
        "value": analytics["scans"].toString(),
        "icon": Icons.analytics,
      },
      {
        "title": "Image Scans",
        "value": analytics["imageScans"].toString(),
        "icon": Icons.photo_camera,
      },
      {
        "title": "Video Scans",
        "value": analytics["videoScans"].toString(),
        "icon": Icons.videocam,
      },
      {
        "title": "Saved Products",
        "value": analytics["savedProducts"].toString(),
        "icon": Icons.favorite,
      },
      {
        "title": "Active Users",
        "value": analytics["users"].toString(),
        "icon": Icons.people,
      },
      {
        "title": "Products",
        "value": analytics["products"].toString(),
        "icon": Icons.inventory_2,
      },
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Analytics"),
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
                const GradientHeaderCard(
                  title: "Platform Performance",
                  subtitle:
                      "Track user engagement and recommendation performance.",
                  icon: Icons.analytics,
                ),

                const SizedBox(height: 25),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: analyticsCards.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) {
                    final item = analyticsCards[index];

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            item["icon"] as IconData,
                            color: Colors.indigo,
                            size: 30,
                          ),

                          const Spacer(),

                          Text(
                            item["value"] as String,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            item["title"] as String,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                const Text(
                  "Platform Overview",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  height: 220,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: analytics["users"].toDouble(),
                              width: 16,
                            ),
                          ],
                        ),

                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: analytics["imageScans"].toDouble(),
                              width: 16,
                            ),
                          ],
                        ),

                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: analytics["videoScans"].toDouble(),
                              width: 16,
                            ),
                          ],
                        ),

                        BarChartGroupData(
                          x: 3,
                          barRods: [
                            BarChartRodData(
                              toY: analytics["products"].toDouble(),
                              width: 16,
                            ),
                          ],
                        ),

                        BarChartGroupData(
                          x: 4,
                          barRods: [
                            BarChartRodData(
                              toY: analytics["savedProducts"].toDouble(),
                              width: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text("Users"),
                    Text("Image"),
                    Text("Video"),
                    Text("Products"),
                    Text("Saved"),
                  ],
                ),

                const SizedBox(height: 25),

                const SizedBox(height: 30),

                const Text(
                  "Top Saved Products",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                ...((analytics["topSavedProducts"] ?? []) as List).map(
                  (product) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: product["imageUrl"] != null &&
                                    product["imageUrl"]
                                        .toString()
                                        .startsWith("http")
                                ? Image.network(
                                    product["imageUrl"],
                                    height: 54,
                                    width: 54,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 54,
                                    width: 54,
                                    color: Colors.indigo.shade50,
                                    child: const Icon(
                                      Icons.inventory_2,
                                      color: Colors.indigo,
                                    ),
                                  ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product["name"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  product["category"],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${product["saveCount"]} saves",
                              style: const TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),
                
                const Text(
                  "Recent Activity",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                ActivityTile(
                  icon: Icons.people,
                  text:
                      "${analytics["users"]} users registered on platform",
                ),

                ActivityTile(
                  icon: Icons.camera_alt,
                  text:
                      "${analytics["scans"]} total scans completed",
                ),

                ActivityTile(
                  icon: Icons.photo_camera,
                  text:
                      "${analytics["imageScans"]} image scans completed",
                ),

                ActivityTile(
                  icon: Icons.videocam,
                  text:
                      "${analytics["videoScans"]} video scans completed",
                ),
                ActivityTile(
                  icon: Icons.favorite,
                  text:
                      "${analytics["savedProducts"]} products saved by users",
                ),
              ],
            ),
    );
  }
}