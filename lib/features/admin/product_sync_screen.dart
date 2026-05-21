import 'package:flutter/material.dart';

class ProductSyncScreen extends StatelessWidget {
  const ProductSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final syncLogs = [
      {"vendor": "Amazon", "status": "Synced", "time": "Today, 10:30 AM"},
      {"vendor": "Flipkart", "status": "Synced", "time": "Today, 09:15 AM"},
      {"vendor": "IKEA", "status": "Pending", "time": "Not synced yet"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Product Sync"),
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
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sync, color: Colors.white, size: 35),
                SizedBox(height: 15),
                Text(
                  "Sync ecommerce products",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Refresh product catalog from connected vendors.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            label: const Text("Start Sync"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Sync History",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          ...syncLogs.map(
            (log) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    log["status"] == "Synced"
                        ? Icons.check_circle
                        : Icons.pending,
                    color: log["status"] == "Synced"
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "${log["vendor"]}\n${log["time"]}",
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                  Text(
                    log["status"]!,
                    style: TextStyle(
                      color: log["status"] == "Synced"
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
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
}