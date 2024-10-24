import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evbooking_operators/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied to clipboard')),
        );
      }
    });
  }

  Widget _buildBookingList(Stream<List<Map<String, dynamic>>> bookingsStream) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: bookingsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No bookings found'));
        }

        final bookings = snapshot.data!;
        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            final createdAt = (booking['createdAt'] as Timestamp).toDate();
            final dateStr =
                DateFormat('MMM dd, yyyy hh:mm a').format(createdAt);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('${booking['uName']} (${booking['designation']})'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${booking['uEmail']}'),
                    Text('From: ${booking['currentLocation']}'),
                    Text('To: ${booking['destination']}'),
                    Text('Date: $dateStr'),
                    if (booking['vehicleNumber'] != null)
                      Text('Vehicle: ${booking['vehicleNumber']}'),
                  ],
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    final bookingDetails =
                        'Name: ${booking['uName']} \nEmail: ${booking['uEmail']}\nFrom: ${booking['currentLocation']}\nTo: ${booking['destination']}\nVehicleNumber: ${booking['vehicleNumber']}\nDate: $dateStr';
                    _copyToClipboard(bookingDetails);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(
              _databaseService.streamBookingsByStatus('approved')),
          _buildBookingList(
              _databaseService.streamBookingsByStatus('rejected')),
          _buildBookingList(
              _databaseService.streamBookingsByStatus('cancelled')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
