import 'package:flutter/material.dart';
import '../scan/scan_screen.dart';
import '../scan/history_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/widgets/bottom_nav_item.dart';
import '../../core/widgets/animated_card.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/widgets/glass_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // BODY
      body: Stack(
        children: [

          // BACKGROUND GRADIENT BLOBS
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigo.withOpacity(0.08),
              ),
            ),
          ),

          Positioned(
            bottom: -100,
            left: -70,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.05),
              ),
            ),
          ),

   
      
      
      
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // TOP HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Hello, Karthik 👋",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "What would you like to do today?",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),

                  const Icon(
                    Icons.notifications_none,
                    size: 28,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ACTION CARDS
              Row(
                children: [
                  Expanded(
                    child: AnimatedCardWrapper(
                      onTap: () {
                        Navigator.push(
                          context,
                          AppRoutes.fadeSlide(
                            const ScanScreen(),
                          ),
                        );
                      },
                      child: _actionCard(
                        icon: Icons.camera_alt_outlined,
                        title: "Scan Space",
                        subtitle: "Use Camera",
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: AnimatedCardWrapper(
                      onTap: () {
                        Navigator.push(
                          context,
                          AppRoutes.fadeSlide(
                            const ScanScreen(),
                          ),
                        );
                      },
                      child: _actionCard(
                        icon: Icons.image_outlined,
                        title: "Upload Image",
                        subtitle: "From Gallery",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // RECENT HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Recent Measurements",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "View All",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // MEASUREMENTS LIST
              Expanded(
                child: ListView(
                  children: [
                    _measurementTile(
                      "Living Room",
                      "12 May, 2024 • 10:30 AM",
                    ),

                    _measurementTile(
                      "Kitchen Area",
                      "11 May, 2024 • 04:20 PM",
                    ),

                    _measurementTile(
                      "Study Table Space",
                      "10 May, 2024 • 09:15 AM",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
        ],
      ),

      // FLOATING CAMERA BUTTON
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4F46E5),
              Color(0xFF6366F1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              AppRoutes.fadeSlide(
                const ScanScreen(),
              ),
            );
          },
          child: const Icon(
            Icons.camera_alt,
            size: 30,
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 10,
        child: SizedBox(
          height: 85,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BottomNavItem(
                icon: Icons.home,
                label: "Home",
                active: currentIndex == 0,
                onTap: () {
                  setState(() => currentIndex = 0);
                },
              ),

              BottomNavItem(
                icon: Icons.history,
                label: "History",
                active: currentIndex == 1,
                onTap: () {
                  setState(() => currentIndex = 1);

                  Navigator.push(
                    context,
                    AppRoutes.fadeSlide(
                      const HistoryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(width: 40),

              BottomNavItem(
                icon: Icons.bookmark_border,
                label: "Saved",
                active: currentIndex == 2,
                onTap: () {
                  setState(() => currentIndex = 2);
                },
              ),

              BottomNavItem(
                icon: Icons.person_outline,
                label: "Profile",
                active: currentIndex == 3,
                onTap: () {
                  setState(() => currentIndex = 3);

                  Navigator.push(
                    context,
                    AppRoutes.fadeSlide(
                      const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ACTION CARD
  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return GlassCard(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.indigo, size: 40),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  // MEASUREMENT TILE
  Widget _measurementTile(String title, String subtitle) {
    return AnimatedCardWrapper(
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.home_work_outlined,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.more_vert),
          ],
        ),
      ),
    );
  }
}