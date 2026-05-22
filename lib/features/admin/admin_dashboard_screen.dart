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
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/admin_menu_tile.dart';

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
              const StatCard(
                title: "Users",
                value: "1,245",
                icon: Icons.people,
              ),
              const SizedBox(width: 14),
              const StatCard(
                title: "Scans",
                value: "842",
                icon: Icons.camera_alt,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const StatCard(
                title: "Products",
                value: "3,520",
                icon: Icons.inventory_2,
              ),
              const SizedBox(width: 14),
              const StatCard(
                title: "Vendors",
                value: "12",
                icon: Icons.store,
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Admin Controls",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          AdminMenuTile(
            icon: Icons.store,
            title: "Vendors",
            subtitle: "Manage ecommerce vendors",
            screen: const VendorsScreen(),
          ),

            AdminMenuTile(
                icon: Icons.inventory_2,
                title: "Product Catalog",
                subtitle: "Manage products",
                screen: const ProductCatalogScreen(),
            ),

            AdminMenuTile(
                icon: Icons.sync,
                title: "Product Sync",
                subtitle: "Sync ecommerce products",
                screen: const ProductSyncScreen(),
            ),

            AdminMenuTile(
                icon: Icons.category,
                title: "Categories",
                subtitle: "Manage room/product categories",
                screen: const CategoriesScreen(),
            ),

            AdminMenuTile(
                icon: Icons.rule,
                title: "Recommendation Rules",
                subtitle: "Configure rules",
                screen: const RecommendationRulesScreen(),
            ),

            AdminMenuTile(
                icon: Icons.analytics,
                title: "Analytics",
                subtitle: "View reports",
                screen: const AnalyticsScreen(),
            ),

            AdminMenuTile(
                icon: Icons.history,
                title: "Scan Logs",
                subtitle: "Monitor scans",
                screen: const ScanLogsScreen(),
            ),

            AdminMenuTile(
                icon: Icons.notifications,
                title: "Notifications",
                subtitle: "Send updates",
                screen: const NotificationsScreen(),
            ),

            AdminMenuTile(
                icon: Icons.settings,
                title: "Profile & Settings",
                subtitle: "Admin settings",
                screen: const AdminSettingsScreen(),
            ),
        ],
      ),
    );
  }
}