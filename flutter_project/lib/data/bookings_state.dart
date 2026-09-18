// lib/data/bookings_state.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// A ValueNotifier to hold the list of booked event IDs
ValueNotifier<List<String>> bookingsNotifier = ValueNotifier([]);

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Function to book an event
Future<void> bookEvent(String eventId) async {
  if (bookingsNotifier.value.contains(eventId)) {
    // Optional: throw an exception or return if already booked
    return;
  }

  final eventRef = _firestore.collection('events').doc(eventId);

  await _firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(eventRef);

    if (!snapshot.exists) {
      throw Exception("Event not found!");
    }

    final eventData = snapshot.data() as Map<String, dynamic>;
    final availableSeats = eventData['availableSeats'] as int;

    if (availableSeats > 0) {
      // Decrement the number of available seats
      transaction.update(eventRef, {'availableSeats': availableSeats - 1});

      // Add a booking document
      final bookingRef = _firestore.collection('bookings').doc();
      transaction.set(bookingRef, {
        'eventId': eventId,
        'bookingTime': FieldValue.serverTimestamp(),

        // You might want to add a userId here in a real app
      });

      // Update the local state
      final newBookings = List<String>.from(bookingsNotifier.value)
        ..add(eventId);
      bookingsNotifier.value = newBookings;
    } else {
      // Handle the case where there are no available seats
      throw Exception("No available seats for this event.");
    }
  });
}

// Function to cancel a booking
Future<void> cancelBooking(String eventId) async {
  if (!bookingsNotifier.value.contains(eventId)) {
    return;
  }

  final eventRef = _firestore.collection('events').doc(eventId);

  await _firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(eventRef);

    if (!snapshot.exists) {
      throw Exception("Event not found!");
    }

    final eventData = snapshot.data() as Map<String, dynamic>;
    final availableSeats = eventData['availableSeats'] as int;

    // Increment the number of available seats
    transaction.update(eventRef, {'availableSeats': availableSeats + 1});

    // Find and delete the booking document
    final bookingQuery = await _firestore
        .collection('bookings')
        .where('eventId', isEqualTo: eventId)
        // Add a .where('userId', isEqualTo: currentUserId) in a real app
        .limit(1)
        .get();

    if (bookingQuery.docs.isNotEmpty) {
      transaction.delete(bookingQuery.docs.first.reference);
    }

    // Update the local state
    final newBookings = List<String>.from(bookingsNotifier.value)
      ..remove(eventId);
    bookingsNotifier.value = newBookings;
  });
}
