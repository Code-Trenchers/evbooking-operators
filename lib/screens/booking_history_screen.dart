import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evbooking_operators/services/database_service.dart';
import 'package:evbooking_operators/services/logger_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Import this for Clipboard functionality

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _approvedBookings = [];
  List<Map<String, dynamic>> _rejectedBookings = [];
  List<Map<String, dynamic>> _cancelledBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final approved = await _databaseService.fetchBookingsByStatus('approved');
      final rejected = await _databaseService.fetchBookingsByStatus('rejected');
      final cancelled =
          await _databaseService.fetchBookingsByStatus('cancelled');

      setState(() {
        _approvedBookings = approved;
        _rejectedBookings = rejected;
        _cancelledBookings = cancelled;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Error fetching bookings', e);
      setState(() => _isLoading = false);
    }
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

  Widget _buildBookingList(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) {
      return const Center(
        child: Text('No bookings found'),
      );
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final createdAt = (booking['createdAt'] as Timestamp).toDate();
        final dateStr = DateFormat('MMM dd, yyyy hh:mm a').format(createdAt);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: SelectableText(
                '${booking['uName']} (${booking['designation']})'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText('Email: ${booking['uEmail']}'),
                SelectableText('From: ${booking['currentLocation']}'),
                SelectableText('To: ${booking['destination']}'),
                SelectableText('Date: $dateStr'),
                if (booking['vehicleNumber'] != null)
                  SelectableText('Vehicle: ${booking['vehicleNumber']}'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(_approvedBookings),
                _buildBookingList(_rejectedBookings),
                _buildBookingList(_cancelledBookings),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchBookings,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
