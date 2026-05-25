import 'package:flutter/material.dart';

class ScanDetailScreen extends StatelessWidget {
  final Map<String, dynamic> scan;

  const ScanDetailScreen({
    super.key,
    required this.scan,
  });

  bool _isValidImageUrl(dynamic url) {
    if (url == null) return false;
    final value = url.toString().trim();
    return value.startsWith("http");
  }

  Color _roomColor(String roomType) {
    switch (roomType) {
      case "Bedroom":
        return Colors.purple;
      case "Kitchen":
        return Colors.orange;
      case "Living Room":
        return Colors.green;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = scan["width"] ?? 0;
    final height = scan["height"] ?? 0;
    final depth = scan["depth"] ?? 0;
    final area = scan["area"] ?? 0;
    final roomType = scan["roomType"] ?? "Study Room";
    final date = scan["createdAt"].toString().substring(0, 10);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Scan Details"),
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
            child: _isValidImageUrl(scan["imageUrl"])
                ? Image.network(
                    scan["imageUrl"],
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 280,
                    color: Colors.indigo.shade50,
                    child: const Icon(
                      Icons.home_work,
                      size: 90,
                      color: Colors.indigo,
                    ),
                  ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _roomColor(roomType).withOpacity(0.12),
                  child: Icon(
                    Icons.auto_awesome,
                    color: _roomColor(roomType),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$roomType Detected",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Saved on $date",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _metricCard("Width", "$width cm")),
              const SizedBox(width: 12),
              Expanded(child: _metricCard("Height", "$height cm")),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _metricCard("Depth", "$depth cm")),
              const SizedBox(width: 12),
              Expanded(child: _metricCard("Area", "$area m²")),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.psychology, color: Colors.indigo),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "This scan was analyzed using the SpaceFit measurement engine and room-aware recommendation logic.",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}