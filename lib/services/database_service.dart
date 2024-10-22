import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evBookingOperators/services/logger_service.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createBooking(
      String uId,
      String uName,
      String uEmail,
      String currentLocation,
      String destination,
      String designation,
      String luggage,
      String purpose) async {
    try {
      LoggerService.info('Attempting to create a new booking for user: $uName');
      await _db.collection('bookings').add({
        'uId': uId,
        'uName': uName,
        'uEmail': uEmail,
        'currentLocation': currentLocation,
        'destination': destination,
        'designation': designation,
        'luggage': luggage,
        'purpose': purpose,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      LoggerService.info('Booking created successfully for user: $uName');
    } catch (e) {
      LoggerService.error('Error creating booking', e);
      rethrow; // Rethrow the error so it can be handled by the caller
    }
  }
}
