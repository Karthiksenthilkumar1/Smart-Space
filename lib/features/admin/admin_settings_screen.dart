import 'package:flutter/material.dart';
import 'admin_profile_screen.dart';
import 'change_password_screen.dart';
import 'about_platform_screen.dart';
import 'help_support_screen.dart';
import 'notification_preferences_screen.dart';
import 'data_management_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_space/core/services/api_service.dart';
import 'package:smart_space/features/auth/login_screen.dart';

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
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(
            const Duration(milliseconds: 400),
          );
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminProfileScreen(),
                  ),
                );
              },
              child: _tile(
                Icons.person,
                "Admin Profile",
                "Update admin information",
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                );
              },
              child: _tile(
                Icons.security,
                "Security Settings",
                "Password and authentication",
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationPreferencesScreen(),
                  ),
                );
              },
              child: _tile(
                Icons.notifications,
                "Notification Preferences",
                "Manage admin alerts",
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DataManagementScreen(),
                  ),
                );
              },
              child: _tile(
                Icons.storage,
                "Data Management",
                "Storage and sync controls",
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HelpSupportScreen(),
                  ),
                );
              },
              child: _tile(
                Icons.help_outline,
                "Help & Support",
                "Contact support team",
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AboutPlatformScreen(),
                  ),
                );
              },
              child: _tile(
                Icons.info_outline,
                "About Platform",
                "SpaceFit Admin v1.0",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();

                await prefs.remove("remembered_email");

                ApiService.authToken = null;

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
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
