import 'package:flutter/material.dart';
import '../scan/scan_screen.dart';
import '../scan/history_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/widgets/bottom_nav_item.dart';
import '../../core/widgets/animated_card.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/widgets/glass_card.dart';
import '../scan/saved_screen.dart';
import '../user/user_notifications_screen.dart';
import '../video/video_capture_screen.dart';
import '../../core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    _loadRecentScans();
  }

  Future<void> _loadRecentScans() async {

    final profileResponse =
        await ApiService.getProfile();

    if (profileResponse["statusCode"] == 200) {
      userName =
          profileResponse["data"]["user"]["name"];
    }

    final unreadResponse =
      await ApiService.getUnreadCount();

    print(
      "REFRESHED COUNT = ${unreadResponse["data"]["count"]}"
    );


    final response =
        await ApiService.getMyScans();

    if (response["statusCode"] == 200) {
      setState(() {

        recentScans =
            response["data"]["scans"];

        if (unreadResponse["statusCode"] == 200) {
          unreadCount =
              unreadResponse["data"]["count"];
          
          print("COUNT FROM API = ${unreadResponse["data"]["count"]}");
        }

        isLoading = false;
      });
    }

    else {
      setState(() {
        isLoading = false;
      });
    }
  }
  int currentIndex = 0;

  bool isLoading = true;
  List recentScans = [];
  String userName = "User";
  int unreadCount = 0;

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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, $userName 👋",
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
                  ),

                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        AppRoutes.fadeSlide(
                          const UserNotificationsScreen(),
                        ),
                      );

                      _loadRecentScans();
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          size: 28,
                        ),

                        if (unreadCount > 0)
                          Positioned(
                            right: -6,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == "logout") {
                        final prefs =
                            await SharedPreferences.getInstance();

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
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "logout",
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text("Logout"),
                          ],
                        ),
                      ),
                    ],
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
                            const VideoCaptureScreen(),
                          ),
                        );
                      },
                      child: _actionCard(
                        icon: Icons.videocam_outlined,
                        title: "Room Video",
                        subtitle: "360° Capture",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),
              
              // RECENT HEADER
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Measurements",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        AppRoutes.fadeSlide(
                          const HistoryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "View All",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount:
                            recentScans.length > 3
                                ? 3
                                : recentScans.length,
                        itemBuilder:
                            (context, index) {
                          final scan =
                              recentScans[index];

                          return _measurementTile(
                            scan["roomType"] ??
                                "Saved Measurement",
                            scan["createdAt"]
                                .toString()
                                .substring(0, 10),
                          );
                        },
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
                onTap: () async {
                  setState(() => currentIndex = 1);

                  await Navigator.push(
                    context,
                    AppRoutes.fadeSlide(
                      const HistoryScreen(),
                    ),
                  );

                  if (mounted) {
                    setState(() => currentIndex = 0);
                  }
                },
              ),

              const SizedBox(width: 40),

              BottomNavItem(
                icon: Icons.bookmark_border,
                label: "Saved",
                active: currentIndex == 2,
                onTap: () async {
                  setState(() => currentIndex = 2);

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedScreen(),
                    ),
                  );

                  if (mounted) {
                    setState(() => currentIndex = 0);
                  }
                },
              ),
              BottomNavItem(
                icon: Icons.person_outline,
                label: "Profile",
                active: currentIndex == 3,
                onTap: () async {
                  setState(() => currentIndex = 3);

                  await Navigator.push(
                    context,
                    AppRoutes.fadeSlide(
                      const ProfileScreen(),
                    ),
                  );

                  if (mounted) {
                    setState(() => currentIndex = 0);
                  }
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