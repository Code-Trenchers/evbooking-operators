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

  /// Navigate to Profile screen (placeholder)
  void navigateToProfile() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Navigating to Profile...'),
    ));
  }

  /// Navigate to Settings screen (placeholder)
  void navigateToSettings() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Navigating to Settings...'),
    ));
  }

  /// Navigate to About screen (placeholder)
  void navigateToAbout() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Navigating to About...'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.grey, // Set AppBar color to grey
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Welcome, ${_user.displayName!}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                navigateToProfile(); // Navigate to Profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                navigateToSettings(); // Navigate to Settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                navigateToAbout(); // Navigate to About
              },
            ),
            const SizedBox(height: 420), // Add space before Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                signUserOut(); // Call the sign-out function
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16.0), // Add some padding around the content
        child: Wrap(
          spacing: 20.0, // Horizontal spacing between items
          runSpacing: 20.0, // Vertical spacing between rows
          children: [
            // Box 1 with grey and mild black fade background
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) -
                  30, // Half of the screen width
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.grey, Colors.black54],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                child: const Center(
                  child: Text(
                    '...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            // Box 2 with grey and mild black fade background
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) -
                  30, // Half of the screen width
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.grey, Colors.black54],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    '...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            // Box 3 with grey and mild black fade background
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) -
                  30, // Half of the screen width
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.grey, Colors.black54],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    '...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            // Box 4 with grey and mild black fade background
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) -
                  30, // Half of the screen width
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.grey, Colors.black54],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    '...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
