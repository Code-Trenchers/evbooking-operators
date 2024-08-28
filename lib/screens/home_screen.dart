import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_page/screens/login_screen.dart';
import 'package:login_page/widgets/error_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final String serverKey = "";

  Future<void> sendMessage() async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "to": "RECEIVER_DEVICE_TOKEN", // Replace with receiver's FCM token
      "notification": {
        "title": "Message from App 1",
        "body": "Hello from another app!",
        "sound": "default",
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "message": "This is a message from App 1"
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final response = await http.post(
      Uri.parse(postUrl),
      body: json.encode(data),
      headers: headers,
    );

    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      print('Failed to send message');
    }
  }

    /// Signs the user out and navigates to the login screen
  Future<void> signUserOut() async {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return; // Check if the widget is still mounted

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
  }

  void buttonAction() {
    try {
      print("Hello");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () => signUserOut(), // Call the function
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: sendMessage,
              child: Text('Send Message to App 2'),
            ),
          ],
        ),
      ),
    );
  }
}
