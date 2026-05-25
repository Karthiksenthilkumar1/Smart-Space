import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.name);

    emailController =
        TextEditingController(text: widget.email);
  }

  Future<void> _saveProfile() async {
    setState(() {
      isLoading = true;
    });

    final response =
        await ApiService.updateProfile(
      name: nameController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (response["statusCode"] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Profile updated successfully"),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["data"]["message"] ??
                "Failed to update profile",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Name",
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: emailController,
            enabled: false,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed:
                  isLoading ? null : _saveProfile,
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      "SAVE CHANGES",
                    ),
            ),
          ),
        ],
      ),
    );
  }
}