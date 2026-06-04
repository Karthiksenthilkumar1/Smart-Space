import 'package:flutter/material.dart';
import 'package:smart_space/core/services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {

  final currentPasswordController =
      TextEditingController();

  final newPasswordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> updatePassword() async {

    if (newPasswordController.text !=
        confirmPasswordController.text) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Passwords do not match",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    final response =
        await ApiService.changePassword(
      currentPassword:
          currentPasswordController.text,
      newPassword:
          newPasswordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (response["statusCode"] == 200) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Password updated successfully",
          ),
        ),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            response["data"]["message"] ??
                "Failed to update password",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FF),

      appBar: AppBar(
        title: const Text(
          "Change Password",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller:
                  currentPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    "Current Password",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
                  newPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    "New Password",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
                  confirmPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    "Confirm Password",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : updatePassword,
                child: Text(
                  isLoading
                      ? "Updating..."
                      : "Update Password",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}