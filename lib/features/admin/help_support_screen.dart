import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Widget infoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.indigo,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FF),

      appBar: AppBar(
        title:
            const Text("Help & Support"),
        centerTitle: true,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [

          const CircleAvatar(
            radius: 45,
            backgroundColor:
                Colors.indigo,
            child: Icon(
              Icons.support_agent,
              size: 45,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              "SpaceFit Support",
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const Center(
            child: Text(
              "Need help? Contact us",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 30),

          infoTile(
            Icons.email,
            "Support Email",
            "support@spacefit.com",
          ),

          infoTile(
            Icons.phone,
            "Support Contact",
            "+91 9876543210",
          ),

          infoTile(
            Icons.language,
            "Website",
            "www.spacefit.com",
          ),

          infoTile(
            Icons.access_time,
            "Working Hours",
            "Mon - Fri | 9 AM - 6 PM",
          ),

          const SizedBox(height: 20),

          Container(
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Text(
              "For technical issues, account access problems, product synchronization errors, or platform-related support, please contact the SpaceFit support team through the channels above.",
              style: TextStyle(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}