import 'package:flutter/material.dart';

class RecommendationRulesScreen extends StatelessWidget {
  const RecommendationRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rules = [
      {
        "title": "Small Room Optimization",
        "description": "Suggest compact furniture for spaces below 100 sq.ft",
        "status": "Active",
      },
      {
        "title": "Living Room Premium",
        "description": "Recommend premium sofas for large living rooms",
        "status": "Active",
      },
      {
        "title": "Kitchen Essentials",
        "description": "Prioritize modular kitchen products",
        "status": "Draft",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Recommendation Rules"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text("Create Rule"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ...rules.map(
            (rule) => Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rule, color: Colors.indigo),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          rule["title"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: rule["status"] == "Active"
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          rule["status"]!,
                          style: TextStyle(
                            color: rule["status"] == "Active"
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    rule["description"]!,
                    style: const TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("Edit"),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                        ),
                        child: const Text("Apply"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}