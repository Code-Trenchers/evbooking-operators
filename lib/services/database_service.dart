import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evbooking_operators/services/logger_service.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchBookingsByStatus(String status,
      {int? limit}) async {
    try {
      LoggerService.info('Fetching $status bookings');
      Query query = _db
          .collection('bookings')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      QuerySnapshot snapshot = await query.get();

      List<Map<String, dynamic>> requests = snapshot.docs.map((doc) {
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
          'vehicleNumber': data['vehicleNumber'],
        };
      }).toList();

      return requests;
    } catch (e) {
      LoggerService.error('Error fetching $status bookings', e);
      return [];
    }
  }
}
