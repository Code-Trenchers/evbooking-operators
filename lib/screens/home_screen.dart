import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evbooking_operators/screens/login_screen.dart';
import 'package:evbooking_operators/services/logger_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  User? _user;
  List<Map<String, dynamic>> _requests = [];
  final List<Map<String, dynamic>> _approvedLogs = [];
  List<bool> _approvedStatus = [];
  int _approvalCount = 0;
  int _cancellationCount = 0;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchRequestsFromFirestore();
  }

  Future<void> _fetchRequestsFromFirestore() async {
    try {
      LoggerService.info('Fetching pending requests from Firestore');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('status', isEqualTo: 'pending')
          .get();

      setState(() {
        _requests = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            'docId': doc.id,
            'createdAt': data['createdAt'],
            'currentLocation': data['currentLocation'],
            'designation': data['designation'],
            'destination': data['destination'],
            'luggage': data['luggage'],
            'purpose': data['purpose'],
            'status': data['status'],
            'uEmail': data['uEmail'],
            'uId': data['uId'],
            'uName': data['uName'],
          };
        }).toList();

        _approvedStatus = List<bool>.filled(_requests.length, false);
      });
      LoggerService.info('Fetched ${_requests.length} pending requests');
    } catch (e) {
      LoggerService.error('Error fetching requests', e);
    }
  }

  Future<void> signUserOut() async {
    try {
      LoggerService.info('Signing out user');
      await FirebaseAuth.instance.signOut();
      LoggerService.info('User signed out successfully');

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      LoggerService.error('Error signing out user', e);
    }
  }

  void _showDetailsDialog(int index) {
    Map<String, dynamic> request = _requests[index];
    String? selectedVehicle;
    List<String> vehicleNumbers = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15'
    ];
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('E-Vehicle Request Details'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text('Name: ${request['uName']}'),
                    Text('Email: ${request['uEmail']}'),
                    Text('Designation: ${request['designation']}'),
                    Text('Current Location: ${request['currentLocation']}'),
                    Text('Destination: ${request['destination']}'),
                    Text('Luggage: ${request['luggage']}'),
                    Text('Purpose: ${request['purpose']}'),
                    Text('Status: ${request['status']}'),
                    Text('Created At: ${request['createdAt'].toDate()}'),
                    const SizedBox(height: 10),
                    const Text('Select Vehicle Number:'),
                    DropdownButton<String>(
                      value: selectedVehicle,
                      hint: const Text('Select Vehicle'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedVehicle = newValue;
                        });
                      },
                      items: vehicleNumbers.map<DropdownMenuItem<String>>(
                        (String vehicle) {
                          return DropdownMenuItem<String>(
                            value: vehicle,
                            child: Text(vehicle),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Approve'),
                  onPressed: () {
                    if (selectedVehicle != null) {
                      Navigator.of(dialogContext).pop();
                      _approveRequest(index, request, selectedVehicle!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a vehicle number'),
                        ),
                      );
                    }
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _cancelRequest(index);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _approveRequest(
      int index, Map<String, dynamic> request, String vehicleNumber) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(request['docId'])
          .update({
        'status': 'approved',
        'vehicleNumber': vehicleNumber,
      });

      setState(() {
        _approvedLogs.insert(0, request);
        _approvalCount++;
        _approvedStatus[index] = true;
      });

      LoggerService.info('Request approved with vehicle $vehicleNumber');
    } catch (e) {
      LoggerService.error('Error updating status', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving request: ${e.toString()}')),
        );
      }
    }
  }

  void _cancelRequest(int index) {
    setState(() {
      _cancellationCount++;
      _approvedStatus[index] = true;
    });
    LoggerService.info('Request cancelled');
  }

  void _showEvLogs() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ev Recent Logs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Approvals: $_approvalCount'),
              Text('Total Cancellations: $_cancellationCount'),
              const SizedBox(height: 10),
              ..._approvedLogs.take(2).map((log) {
                return ListTile(
                  title: Text('Approved: ${log['uEmail']}'),
                  subtitle: Text(
                      'From: ${log['currentLocation']} To: ${log['destination']}'),
                );
              }),
              if (_approvedLogs.length > 2)
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
            colors: [Colors.white, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: <Widget>[
            // Top bar with rounded corners
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
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
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: const [
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
                        Expanded(
                          child: Text(
                            '${index + 1}. Request from: ${_requests[index]['uName']}',
                            style: const TextStyle(fontSize: 18.0),
                            overflow: TextOverflow.ellipsis,
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
      // Reload button
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchRequestsFromFirestore,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
