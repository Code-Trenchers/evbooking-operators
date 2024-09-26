import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a booking
  Future<void> createBooking(String uId, String uName, String uPhone, String currentLocation, String destination, String designation, String luggage, String purpose) async {
    await _db.collection('bookings').add({
      'uId': uId,
      'uName': uName,
      'uPhone': uPhone,
      'currentLocation': currentLocation,
      'destination': destination,
      'designation': designation,
      'luggage': luggage,
      'purpose': purpose,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
