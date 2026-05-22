import 'package:flutter/material.dart';
import '../../core/widgets/gradient_header_card.dart';
import '../../core/widgets/activity_tile.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = [
      {
        "title": "Total Scans",
        "value": "12,540",
        "icon": Icons.camera_alt,
      },
      {
        "title": "Recommendations",
        "value": "8,920",
        "icon": Icons.recommend,
      },
      {
        "title": "Active Users",
        "value": "1,245",
        "icon": Icons.people,
      },
      {
        "title": "Vendor Products",
        "value": "3,520",
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const GradientHeaderCard(
            title: "Platform Performance",
            subtitle: "Track user engagement and recommendation performance.",
            icon: Icons.analytics,
          ),

          const SizedBox(height: 25),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: analytics.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final item = analytics[index];

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: const TextStyle(color: Colors.grey),
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

          const ActivityTile(
            icon: Icons.camera_alt,
            text: "245 new scans completed today",
          ),

            const ActivityTile(
            icon: Icons.sync,
            text: "Amazon products synced successfully",
          ),

            const ActivityTile(
            icon: Icons.recommend,
            text: "New recommendation rules applied",
          ),
        ],
      ),
    );
  }
}