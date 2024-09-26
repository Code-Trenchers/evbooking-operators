import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_page/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final String serverKey = "";
  User? _user;
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _approvedLogs = [];
  List<bool> _approvedStatus = [];
  int _approvalCount = 0;
  int _cancellationCount = 0;



  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    _requests = [
      {
        'mailId': 'exa@mail.com',
        'regNo': 'ABC1234',
        'from': 'Campus A',
        'to': 'Campus B',
        'designation': 'Student',
        'luggageStatus': 'Yes',
        'specification': '',
      },
      {
        'mailId': 'ple@mail.com',
        'regNo': 'ABC1234',
        'from': 'Campus A',
        'to': 'Campus B',
        'designation': 'Student',
        'luggageStatus': 'Yes',
        'specification': '',
      },
      {
        'mailId': 'example@mail.com',
        'regNo': 'ABC1234',
        'from': 'Campus A',
        'to': 'Campus B',
        'designation': 'Student',
        'luggageStatus': 'Yes',
        'specification': '',
      },

    ];
    // Initialize the approval status list
    _approvedStatus = List<bool>.filled(_requests.length, false);
  }


  Future<void> signUserOut() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _showDetailsDialog(int index) {
    Map<String, dynamic> request = _requests[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('E-Vehicle Request Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Mail ID: ${request['mailId']}'),
                Text('Reg No: ${request['regNo']}'),
                Text('From: ${request['from']}'),
                Text('To: ${request['to']}'),
                Text('Designation: ${request['designation']}'),
                Text('Luggage Status: ${request['luggageStatus']}'),
                Text('Specification: ${request['specification']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                setState(() {
                  _approvedLogs.insert(0,request);
                  _approvalCount++;
                  _approvedStatus[index] = true; // Mark as approved
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                setState(() {
                  _cancellationCount++;
                  _approvedStatus[index] = true; // Mark as unapproved
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEvLogs() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ev-Logs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Approvals: $_approvalCount'),
              Text('Total Cancellations: $_cancellationCount'),
              const SizedBox(height: 10),
              ..._approvedLogs.take(2).map((log) {
                return ListTile(
                  title: Text('Approved: ${log['mailId']}'),
                  subtitle: Text('From: ${log['from']} To: ${log['to']}'),
                );
              }).toList(),
              if (_approvedLogs.length > 2) // Show a message if there are more than two
                Text('And ${_approvedLogs.length - 2} more...'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
              ),
              accountName: Text(_user?.displayName ?? ''),
              accountEmail: Text(_user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _user?.photoURL != null
                    ? NetworkImage(_user!.photoURL!)
                    : null,
                child: _user?.photoURL == null
                    ? Text(
                        _user?.displayName?.substring(0, 1) ?? 'G',
                        style: const TextStyle(fontSize: 40.0),
                      )
                    : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Recent Approval'),
              onTap: () {
                Navigator.pop(context);
                _showEvLogs();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                signUserOut();
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: <Widget>[
            // Top bar with rounded corners
            Container(
              margin: const EdgeInsets.all(16.0), // Margin around the bar
              padding: const EdgeInsets.all(16.0), // Padding inside the bar
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0), // Rounded corners
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4), // Shadow position
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'REQUEST APPROVE',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  if (_approvedStatus[index]) {
                    return SizedBox.shrink(); // Skip approved requests
                  }
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded( // Use Expanded here
                          child: Text(
                            '${index + 1}. Request from: ${_requests[index]['mailId']}',
                            style: TextStyle(fontSize: 18.0),
                            overflow: TextOverflow.ellipsis, // Prevent overflow
                            maxLines: 1, // Limit to one line
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.visibility_sharp),
                          onPressed: () => _showDetailsDialog(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}