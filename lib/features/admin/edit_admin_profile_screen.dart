import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class EditAdminProfileScreen extends StatefulWidget {
  final Map profile;

  const EditAdminProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditAdminProfileScreen> createState() =>
      _EditAdminProfileScreenState();
}

class _EditAdminProfileScreenState
    extends State<EditAdminProfileScreen> {

  late TextEditingController nameController;
  late TextEditingController emailController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(
      text: widget.profile["name"],
    );

    emailController =
        TextEditingController(
      text: widget.profile["email"],
    );
  }

  Future<void> saveProfile() async {
    setState(() {
      isSaving = true;
    });

    final response =
        await ApiService.updateAdminProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
    );

    setState(() {
      isSaving = false;
    });

    if (response["statusCode"] == 200) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(
                labelText: "Name",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration:
                  const InputDecoration(
                labelText: "Email",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isSaving
                        ? null
                        : saveProfile,
                child: Text(
                  isSaving
                      ? "Saving..."
                      : "Save Changes",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}