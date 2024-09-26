import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_page/screens/login_screen.dart';
import 'package:login_page/services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final String serverKey = "";
  User? _user;
  final DatabaseService _databaseService = DatabaseService();



  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

  void _submitDetails() async {
    if (_user != null) {
      String purpose = _selectedPurpose == 'Other' ? _otherPurposeText ?? 'Unknown' : _selectedPurpose ?? 'Unknown';

      try {
        await _databaseService.createBooking(
          _user!.uid,
          _user!.displayName ?? 'Unknown',
          _user!.email ?? 'Unknown',
          _selectedLocation ?? 'Unknown',
          _selectedDestination ?? 'Unknown',
          _selectedDesignation ?? 'Unknown',
          _selectedLuggageStatus ?? 'Unknown',
          purpose,
        );
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _selectedDesignation = null;
          _selectedLuggageStatus = null;
          _selectedPurpose = null;
          _selectedLocation = null;
          _otherPurposeText = null;
          _selectedDestination = null;
        });
      } catch (e) {
        if (!mounted) return;
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
    // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit request: User not logged in'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Book Your Slot',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dropdown for Current Location
                      DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        decoration: InputDecoration(
                          labelText: 'Current Location',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: _locations.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLocation = newValue;
                            _selectedDestination = null;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Dropdown for Destination Location
                      DropdownButtonFormField<String>(
                        value: _selectedDestination,
                        decoration: InputDecoration(
                          labelText: 'Destination Location',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: _locations
                            .where((location) => location != _selectedLocation)
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDestination = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Designation
                      DropdownButtonFormField<String>(
                        value: _selectedDesignation,
                        decoration: InputDecoration(
                          labelText: 'Designation',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: <String>['Student', 'Faculty', 'Technician']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDesignation = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Luggage Status
                      DropdownButtonFormField<String>(
                        value: _selectedLuggageStatus,
                        decoration: InputDecoration(
                          labelText: 'Luggage Available Status',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: <String>['Yes', 'No'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLuggageStatus = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      if (_selectedLuggageStatus == 'No') ...[
                        // Purpose Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedPurpose,
                          decoration: InputDecoration(
                            labelText: 'Purpose',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: <String>['Meeting', '.', '.', 'Other']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedPurpose = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Other Purpose Text Field
                        if (_selectedPurpose == 'Other') ...[
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Specify',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (text) {
                              setState(() {
                                _otherPurposeText = text;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],

                      // Submit Button with Ripple Effect
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white, 
                        ),
                        onPressed: _submitDetails,
                        child: const Text('Submit'),
                      ),
                    ],
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