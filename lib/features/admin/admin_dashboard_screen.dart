import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';
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

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  bool isLoading = true;

  Map analytics = {};
  List vendors = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final analyticsResponse = await ApiService.getAnalytics();
    final vendorResponse = await ApiService.getVendors();

    if (analyticsResponse["statusCode"] == 200 &&
        vendorResponse["statusCode"] == 200) {
      setState(() {
        analytics = analyticsResponse["data"]["analytics"];
        vendors = vendorResponse["data"]["vendors"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  String _value(dynamic value) {
    return (value ?? 0).toString();
  }

  @override
Widget build(BuildContext context) {
  final users = _value(analytics["users"]);
  final scans = _value(analytics["scans"]);
  final products = _value(analytics["products"]);
  final vendorCount = vendors.length.toString();

  return PopScope(
    canPop: false,
    child: Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      StatCard(
                        title: "Users",
                        value: users,
                        icon: Icons.people,
                      ),
                      const SizedBox(width: 14),
                      StatCard(
                        title: "Scans",
                        value: scans,
                        icon: Icons.camera_alt,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      StatCard(
                        title: "Products",
                        value: products,
                        icon: Icons.inventory_2,
                      ),
                      const SizedBox(width: 14),
                      StatCard(
                        title: "Vendors",
                        value: vendorCount,
                        icon: Icons.store,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Admin Controls",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const AdminMenuTile(
                    icon: Icons.store,
                    title: "Vendors",
                    subtitle: "Manage ecommerce vendors",
                    screen: VendorsScreen(),
                  ),

                  const AdminMenuTile(
                    icon: Icons.inventory_2,
                    title: "Product Catalog",
                    subtitle: "Manage products",
                    screen: ProductCatalogScreen(),
                  ),

                  const AdminMenuTile(
                    icon: Icons.sync,
                    title: "Product Sync",
                    subtitle: "Sync ecommerce products",
                    screen: ProductSyncScreen(),
                  ),

                  const AdminMenuTile(
                    icon: Icons.category,
                    title: "Categories",
                    subtitle: "Manage room/product categories",
                    screen: CategoriesScreen(),
                  ),

                  const AdminMenuTile(
                    icon: Icons.rule,
                    title: "Recommendation Rules",
                    subtitle: "Configure rules",
                    screen: RecommendationRulesScreen(),
                  ),

                  const AdminMenuTile(
                    icon: Icons.analytics,
                    title: "Analytics",
                    subtitle: "View reports",
                    screen: AnalyticsScreen(),
                  ),

                  const AdminMenuTile(
                    icon: Icons.history,
                    title: "Scan Logs",
                    subtitle: "Monitor scans",
                    screen: ScanLogsScreen(),
                  ),

                  const AdminMenuTile(
                    icon: Icons.notifications,
                    title: "Notifications",
                    subtitle: "Send updates",
                    screen: NotificationsScreen(),
                  ),

                  const AdminMenuTile(
                    icon: Icons.settings,
                    title: "Profile & Settings",
                    subtitle: "Admin settings",
                    screen: AdminSettingsScreen(),
                  ),
                ],
              ),
            ),
        ),
    );
  }
}