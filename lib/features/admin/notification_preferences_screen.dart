import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class NotificationPreferencesScreen
    extends StatefulWidget {

  const NotificationPreferencesScreen({
    super.key,
  });

  @override
  State<NotificationPreferencesScreen>
      createState() =>
          _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {

  bool isLoading = true;

  bool scanAlerts = true;
  bool productSyncAlerts = true;
  bool systemNotifications = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {

    final response =
        await ApiService.getAdminSettings();

    if (response["statusCode"] == 200) {

      final settings =
          response["data"]["settings"];

      setState(() {
        scanAlerts =
            settings["scanAlerts"];
        productSyncAlerts =
            settings["productSyncAlerts"];
        systemNotifications =
            settings["systemNotifications"];
        isLoading = false;
      });

    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveSettings() async {

    await ApiService.updateAdminSettings(
      scanAlerts: scanAlerts,
      productSyncAlerts:
          productSyncAlerts,
      systemNotifications:
          systemNotifications,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Settings updated",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FF),

      appBar: AppBar(
        title: const Text(
          "Notification Preferences",
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView(
              padding:
                  const EdgeInsets.all(20),
              children: [

                SwitchListTile(
                  value: scanAlerts,
                  title: const Text(
                    "Scan Alerts",
                  ),
                  subtitle: const Text(
                    "Notify when new scans are created",
                  ),
                  onChanged: (value) {
                    setState(() {
                      scanAlerts = value;
                    });
                  },
                ),

                SwitchListTile(
                  value:
                      productSyncAlerts,
                  title: const Text(
                    "Product Sync Alerts",
                  ),
                  subtitle: const Text(
                    "Notify when sync completes",
                  ),
                  onChanged: (value) {
                    setState(() {
                      productSyncAlerts =
                          value;
                    });
                  },
                ),

                SwitchListTile(
                  value:
                      systemNotifications,
                  title: const Text(
                    "System Notifications",
                  ),
                  subtitle: const Text(
                    "General platform updates",
                  ),
                  onChanged: (value) {
                    setState(() {
                      systemNotifications =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        saveSettings,
                    child: const Text(
                      "Save Preferences",
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}