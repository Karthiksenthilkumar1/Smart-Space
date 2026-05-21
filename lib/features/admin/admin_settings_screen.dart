import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Admin Settings"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.indigo,
            child: Icon(
              Icons.admin_panel_settings,
              size: 45,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 15),

          const Center(
            child: Text(
              "Admin Panel",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Center(
            child: Text(
              "Manage system settings and controls",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 30),

          _tile(
            Icons.person,
            "Admin Profile",
            "Update admin information",
          ),

          _tile(
            Icons.security,
            "Security Settings",
            "Password and authentication",
          ),

          _tile(
            Icons.notifications,
            "Notification Preferences",
            "Manage admin alerts",
          ),

          _tile(
            Icons.storage,
            "Data Management",
            "Storage and sync controls",
          ),

          _tile(
            Icons.help_outline,
            "Help & Support",
            "Contact support team",
          ),

          _tile(
            Icons.info_outline,
            "About Platform",
            "SpaceFit Admin v1.0",
          ),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}