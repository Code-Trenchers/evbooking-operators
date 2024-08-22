import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new customer
  Future<void> addUser(String uid, String name, String phone, String email) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'email': email,
    });
  }

  // Add a new driver
  Future<void> addDriver(String uid, String name, String phone, String email) async {
    await _db.collection('drivers').doc(uid).set({
      'name': name,
      'phone': phone,
      'email': email,
      'status': 'offline',
    });
  }

  // Create a booking
  Future<void> createBooking(String customerId, String customerName, String customerPhone, String driverId, String driverName) async {
    await _db.collection('bookings').add({
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'driverId': driverId,
      'driverName': driverName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Accept a booking
  Future<void> acceptBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }
}
