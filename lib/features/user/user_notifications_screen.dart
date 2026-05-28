import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class UserNotificationsScreen extends StatefulWidget {
  const UserNotificationsScreen({super.key});

  @override
  State<UserNotificationsScreen> createState() =>
      _UserNotificationsScreenState();
}

class _UserNotificationsScreenState
    extends State<UserNotificationsScreen> {
  bool isLoading = true;
  List notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final response =
        await ApiService.getUserNotifications();

    if (response["statusCode"] == 200) {
      setState(() {
        notifications =
            response["data"]["notifications"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  IconData _getIcon(String title) {
    final text = title.toLowerCase();

    if (text.contains("product")) {
      return Icons.inventory_2;
    }

    if (text.contains("scan")) {
      return Icons.camera_alt;
    }

    if (text.contains("rule")) {
      return Icons.auto_awesome;
    }

    return Icons.notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No notifications yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      "Latest updates from SpaceFit",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ...notifications.map((notification) {
                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: Icon(
                                _getIcon(
                                  notification["title"] ?? "",
                                ),
                                color: Colors.indigo,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification["title"] ?? "",
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    notification["message"] ?? "",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    notification["createdAt"] ?? "",
                                    style: const TextStyle(
                                      color: Colors.indigo,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}