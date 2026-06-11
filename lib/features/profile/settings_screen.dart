import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  bool notifications = true;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs =
        await SharedPreferences.getInstance();

    setState(() {
      notifications =
          prefs.getBool("notifications") ?? true;

      darkMode =
          prefs.getBool("darkMode") ?? false;
    });
  }

  Future<void> _saveNotifications(
      bool value) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      "notifications",
      value,
    );

    setState(() {
      notifications = value;
    });
  }

  Future<void> _saveDarkMode(
      bool value) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      "darkMode",
      value,
    );

    setState(() {
      darkMode = value;
    });
  }

  Future<void> _clearCache() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove("notifications");
    await prefs.remove("darkMode");

    setState(() {
      notifications = true;
      darkMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "App cache cleared successfully",
        ),
      ),
    );
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Privacy & Security"),
          content: const Text(
            "Your account is protected using JWT authentication. Uploaded scan images are securely stored.",
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("SpaceFit"),
          content: const Text(
            "Version: 1.0.0\nBuild: 1",
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          darkMode ? Colors.black : const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor:
            darkMode ? Colors.white : Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _switchTile(
            icon: Icons.notifications_none,
            title: "Notifications",
            value: notifications,
            onChanged: _saveNotifications,
          ),

          _switchTile(
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            value: darkMode,
            onChanged: _saveDarkMode,
          ),

          _actionTile(
            icon:
                Icons.cleaning_services_outlined,
            title: "Clear Cache",
            subtitle:
                "Reset local app preferences",
            onTap: _clearCache,
          ),

          _actionTile(
            icon: Icons.security_outlined,
            title: "Privacy",
            subtitle:
                "View privacy information",
            onTap: _showPrivacyInfo,
          ),

          _actionTile(
            icon: Icons.info_outline,
            title: "App Version",
            subtitle:
                "SpaceFit v1.0.0 Build 1",
            onTap: _showAppInfo,
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            darkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: darkMode
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              darkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.indigo),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                      color: darkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.info_outline,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}