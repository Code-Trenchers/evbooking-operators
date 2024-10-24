import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evbooking_operators/services/logger_service.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> streamBookingsByStatus(String status) {
    return _db
        .collection('bookings')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
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
            }).toList())
        .handleError((error) {
      LoggerService.error('Error streaming $status bookings', error);
      return [];
    });
  }
}
