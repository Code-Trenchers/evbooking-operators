import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evbooking_operators/screens/login_screen.dart';
import 'package:evbooking_operators/services/auth_service.dart';
import 'package:evbooking_operators/services/logger_service.dart';
import 'package:evbooking_operators/services/database_service.dart';
import 'package:evbooking_operators/screens/booking_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  User? _user;
  List<Map<String, dynamic>> _requests = [];
  List<bool> _approvedStatus = [];
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchRequestsFromFirestore();
  }

  Future<void> _fetchRequestsFromFirestore() async {
    try {
      LoggerService.info('Fetching pending requests from Firestore');
      List<Map<String, dynamic>>? fetchedRequests =
          await _databaseService.fetchBookingsByStatus('pending');

      setState(() {
        _requests = fetchedRequests;
        _approvedStatus = List<bool>.filled(_requests.length, false);
      });
      LoggerService.info('Fetched ${_requests.length} pending requests');
    } catch (e) {
      LoggerService.error('Error fetching requests', e);
    }
  }

  void _showDetailsDialog(int index) {
    Map<String, dynamic> request = _requests[index];
    String? selectedVehicle;
    void showVehicleSelectionDialog(int index, Map<String, dynamic> request) {
      List<String> vehicleNumbers = [];
      for (var i = 1; i <= 15; i++) {
        vehicleNumbers.add(i.toString());
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text('Select Vehicle'),
                content: DropdownButton<String>(
                  value: selectedVehicle,
                  hint: const Text('Choose a vehicle'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedVehicle = newValue;
                    });
                  },
                  items: vehicleNumbers.map<DropdownMenuItem<String>>(
                    (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    },
                  ).toList(),
                ),
                actions: [
                  TextButton(
                    child: const Text('Confirm'),
                    onPressed: () {
                      if (selectedVehicle != null) {
                        Navigator.of(context).pop();
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
                    child: const Text('Reject'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _rejectRequest(index);
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('E-Vehicle Request Details'),
              content: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(children: [
                      const TableCell(
                          child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Field',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      const TableCell(
                          child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Value',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Name'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          request['uName'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Email'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          request['uEmail'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Designation'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          request['designation'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Current Location'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          request['currentLocation'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Destination'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          request['destination'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Luggage'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          request['luggage'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Purpose'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          request['purpose'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Status'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          request['status'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Created At'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          request['createdAt'].toDate().toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Approve'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    showVehicleSelectionDialog(index, request);
                  },
                ),
                TextButton(
                  child: const Text('Reject'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _rejectRequest(index);
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
        _approvedStatus[index] = true;
        _requests.removeAt(index);
      });

      LoggerService.info('Request approved with vehicle $vehicleNumber');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Request approved with vehicle $vehicleNumber')),
        );
      }
    } catch (e) {
      LoggerService.error('Error updating status', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving request: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _rejectRequest(int index) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(_requests[index]['docId'])
          .update({
        'status': 'rejected',
      });

      setState(() {
        _approvedStatus[index] = true;
        _requests.removeAt(index);
      });

      LoggerService.info('Request denied');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request denied')),
        );
      }
    } catch (e) {
      LoggerService.error('Error rejecting request', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting request: ${e.toString()}')),
        );
      }
    }
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
              leading: const Icon(Icons.history),
              title: const Text('Booking History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingHistoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _authService.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
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
