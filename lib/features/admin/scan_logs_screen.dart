import 'package:flutter/material.dart';

class ScanLogsScreen extends StatelessWidget {
  const ScanLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = [
      {
        "user": "Karthik",
        "room": "Living Room",
        "time": "Today • 10:42 AM",
        "status": "Completed",
      },
      {
        "user": "Rahul",
        "room": "Kitchen",
        "time": "Today • 09:15 AM",
        "status": "Completed",
      },
      {
        "user": "Ananya",
        "room": "Bedroom",
        "time": "Yesterday • 07:30 PM",
        "status": "Pending",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Scan Logs"),
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
              hintText: "Search logs",
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

          ...logs.map(
            (log) => Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.indigo,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${log["user"]} • ${log["room"]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          log["time"]!,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: log["status"] == "Completed"
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      log["status"]!,
                      style: TextStyle(
                        color: log["status"] == "Completed"
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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