import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Help & Support"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _helpTile(
            Icons.camera_alt_outlined,
            "How to scan a space?",
            "Use camera or gallery upload, then wait for AI measurement result.",
          ),
          _helpTile(
            Icons.straighten,
            "How measurements work?",
            "SpaceFit analyzes the uploaded image and estimates usable space dimensions.",
          ),
          _helpTile(
            Icons.recommend_outlined,
            "How recommendations work?",
            "Products are suggested based on room type, dimensions, and available space.",
          ),
          _helpTile(
            Icons.history,
            "Where are my scans saved?",
            "Saved measurements are available in the History section.",
          ),
          _helpTile(
            Icons.bookmark_border,
            "Where are saved products?",
            "Bookmarked recommendations are available in the Saved section.",
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Need more help? Contact SpaceFit support.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _helpTile(IconData icon, String title, String subtitle) {
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
                  subtitle,
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