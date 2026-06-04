import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';
import 'edit_admin_profile_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() =>
      _AdminProfileScreenState();
}

class _AdminProfileScreenState
    extends State<AdminProfileScreen> {

  bool isLoading = true;

  Map profile = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final response =
        await ApiService.getAdminProfile();

    if (response["statusCode"] == 200) {
      setState(() {
        profile = response["data"]["profile"];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Admin Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
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

                const SizedBox(height: 20),

                _infoTile(
                  "Name",
                  profile["name"] ?? "-",
                ),

                _infoTile(
                  "Email",
                  profile["email"] ?? "-",
                ),

                _infoTile(
                  "Role",
                  profile["role"] ?? "-",
                ),

                _infoTile(
                  "Joined",
                  profile["createdAt"] ?? "-",
                ),

                const SizedBox(height: 20),

                SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text(
                    "Edit Profile",
                    ),
                    onPressed: () async {

                    final result =
                        await Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (_) =>
                            EditAdminProfileScreen(
                            profile: profile,
                        ),
                        ),
                    );

                    if (result == true) {
                        _loadProfile();
                    }
                    },
                ),
                ),
              ],
            ),
    );
  }

  Widget _infoTile(
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}