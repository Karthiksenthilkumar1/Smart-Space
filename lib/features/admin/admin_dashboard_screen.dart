import 'package:flutter/material.dart';
import 'vendors_screen.dart';
import 'product_catalog_screen.dart';
import 'product_sync_screen.dart';
import 'categories_screen.dart';
import 'recommendation_rules_screen.dart';
import 'analytics_screen.dart';
import 'notifications_screen.dart';
import 'admin_settings_screen.dart';
import 'scan_logs_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Overview",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _statCard("Users", "1,245", Icons.people),
              const SizedBox(width: 14),
              _statCard("Scans", "842", Icons.camera_alt),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _statCard("Products", "3,520", Icons.inventory_2),
              const SizedBox(width: 14),
              _statCard("Vendors", "12", Icons.store),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Admin Controls",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          _menuTile(
            context,
            Icons.store,
            "Vendors",
            "Manage ecommerce vendors",
            const VendorsScreen(),
          ),

          _menuTile(
            context,
            Icons.inventory_2,
            "Product Catalog",
            "Manage products",
            const ProductCatalogScreen(),
          ),

          _menuTile(
            context,
            Icons.sync,
            "Product Sync",
            "Sync ecommerce products",
            const ProductSyncScreen(),
          ),

          _menuTile(
            context,
            Icons.category,
            "Categories",
            "Manage room/product categories",
            const CategoriesScreen(),
          ),

          _menuTile(
            context,
            Icons.rule,
            "Recommendation Rules",
            "Configure rules",
            const RecommendationRulesScreen(),
          ),

          _menuTile(
            context,
            Icons.analytics,
            "Analytics",
            "View reports",
            const AnalyticsScreen(),
          ),

          _menuTile(
            context,
            Icons.history,
            "Scan Logs",
            "Monitor scans",
            const ScanLogsScreen(),
          ),

          _menuTile(
            context,
            Icons.notifications,
            "Notifications",
            "Send updates",
            const NotificationsScreen(),
          ),

          _menuTile(
            context,
            Icons.settings,
            "Profile & Settings",
            "Admin settings",
            const AdminSettingsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.indigo),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
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
      ),
    );
  }
}