import 'package:flutter/material.dart';
import 'package:recipe_app/components/navigation_bar.dart';
import 'package:recipe_app/constants/colors.dart';

class UploadSuccessDialog extends StatelessWidget {
  final String message;
  final String title;
  final String userId;

  const UploadSuccessDialog({
    super.key,
    required this.message,
    required this.title,
    required this.userId, // Add userId parameter
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 50, color: Colors.orange),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NavBar(userId: userId), // Use the passed userId
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text("Back to Home",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
