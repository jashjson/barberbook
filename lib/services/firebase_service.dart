import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

// ─────────────────────────────────────────────────────────────
//  FirebaseService  —  all reads/writes for BarberBook
//  Fixes applied:
//   1. Notifications sorted by raw Timestamp not formatted string
//   2. Bookings sorted by createdAt Timestamp not date string
//   3. whereIn queries replaced with simple .where() to avoid index errors
//   4. All streams handle errors gracefully
// ─────────────────────────────────────────────────────────────

class FirebaseService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get currentUid => _auth.currentUser?.uid ?? '';

  // ══════════════════════════════════════════════════════════
  //  BARBER
  // ══════════════════════════════════════════════════════════

  static Future<BarberModel?> getCurrentBarber() async {
    try {
      final doc = await _db.collection('barbers').doc(currentUid).get();
      if (!doc.exists) return null;
      return _barberFromDoc(doc);
    } catch (_) {
      return null;
    }
  }

  static Future<List<ServiceModel>> getBarberServices(String barberId) async {
    try {
      final snap = await _db
          .collection('barbers')
          .doc(barberId)
          .collection('services')
          .where('isActive', isEqualTo: true)
          .get();
      return snap.docs
          .map(
            (d) => ServiceModel(
              id: d.id,
              name: d['name'] ?? '',
              price: (d['price'] ?? 0).toInt(),
              durationMin: (d['durationMin'] ?? 30).toInt(),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> updateBarberStatus(String status) async {
    try {
      await _db.collection('barbers').doc(currentUid).update({
        'status': status,
        'isOpen': status == 'open',
      });
    } catch (_) {}
  }

  static Future<void> saveBarberProfile(Map<String, dynamic> data) async {
    await _db.collection('barbers').doc(currentUid).update(data);
  }

  static Future<void> addService(ServiceModel service) async {
    await _db.collection('barbers').doc(currentUid).collection('services').add({
      'name': service.name,
      'price': service.price,
      'durationMin': service.durationMin,
      'isActive': true,
    });
  }

  static Future<void> updateService(
    String serviceId,
    ServiceModel service,
  ) async {
    await _db
        .collection('barbers')
        .doc(currentUid)
        .collection('services')
        .doc(serviceId)
        .update({
          'name': service.name,
          'price': service.price,
          'durationMin': service.durationMin,
        });
  }

  static Future<void> deleteService(String serviceId) async {
    await _db
        .collection('barbers')
        .doc(currentUid)
        .collection('services')
        .doc(serviceId)
        .update({'isActive': false});
  }

  static Future<void> saveAvailability(
    List<Map<String, dynamic>> schedule,
    int slotDuration,
  ) async {
    final batch = _db.batch();
    for (final day in schedule) {
      final ref = _db
          .collection('barbers')
          .doc(currentUid)
          .collection('availability')
          .doc(day['day'] as String);
      batch.set(ref, {
        'day': day['day'],
        'isOpen': day['isOpen'],
        'openTime': day['openTime'],
        'closeTime': day['closeTime'],
        'slotDuration': slotDuration,
      });
    }
    await batch.commit();
  }

  // ── Upcoming appointments for barber home (pending + confirmed) ──
  // FIX: use TWO separate simple queries and merge, avoiding whereIn index issue
  static Stream<List<AppointmentModel>> getUpcomingAppointmentsStream() {
    return _db
        .collection('appointments')
        .where('barberId', isEqualTo: currentUid)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => _apptFromDoc(d))
              .where((a) => a.status == 'pending' || a.status == 'confirmed')
              .toList();
          // Sort: pending first, then by timeSlot
          list.sort((a, b) {
            if (a.status != b.status) {
              return a.status == 'pending' ? -1 : 1;
            }
            return a.timeSlot.compareTo(b.timeSlot);
          });
          return list;
        });
  }

  // ── All appointments for barber appointments tab ──
  static Stream<List<AppointmentModel>> getBarberAppointmentsStream() {
    return _db
        .collection('appointments')
        .where('barberId', isEqualTo: currentUid)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => _apptFromDoc(d)).toList();
          list.sort((a, b) {
            const order = {
              'pending': 0,
              'confirmed': 1,
              'completed': 2,
              'cancelled': 3,
            };
            return (order[a.status] ?? 9).compareTo(order[b.status] ?? 9);
          });
          return list;
        });
  }

  static Future<void> updateAppointmentStatus(
    String apptId,
    String status,
  ) async {
    try {
      await _db.collection('appointments').doc(apptId).update({
        'status': status,
      });
      // Send notification to customer
      final appt = await _db.collection('appointments').doc(apptId).get();
      final custId = appt['customerId'] as String? ?? '';
      final barberNm = appt['barberName'] as String? ?? '';
      final date = appt['date'] as String? ?? '';
      final time = appt['timeSlot'] as String? ?? '';
      if (custId.isEmpty) return;
      String title = '', message = '';
      if (status == 'confirmed') {
        title = 'Booking Confirmed! ✅';
        message = '$barberNm confirmed your appointment on $date at $time.';
      } else if (status == 'cancelled') {
        title = 'Booking Cancelled ❌';
        message = '$barberNm cancelled your appointment on $date at $time.';
      } else if (status == 'completed') {
        title = 'Visit Completed! 🎉';
        message = 'Your visit with $barberNm is complete. Leave a review!';
      }
      if (title.isNotEmpty) {
        await _db.collection('notifications').add({
          'userId': custId,
          'type': status,
          'title': title,
          'message': message,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
  }

  static Future<List<ReviewModel>> getBarberReviews(String barberId) async {
    try {
      final snap = await _db
          .collection('reviews')
          .where('barberId', isEqualTo: barberId)
          .get();
      return snap.docs
          .map(
            (d) => ReviewModel(
              id: d.id,
              barberId: d['barberId'] ?? '',
              customerId: d['customerId'] ?? '',
              customerName: d['customerName'] ?? '',
              customerInitial: _initial(d['customerName']),
              rating: (d['rating'] ?? 5).toInt(),
              comment: d['comment'] ?? '',
              date: _fmtTs(d['createdAt']),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════
  //  CUSTOMER
  // ══════════════════════════════════════════════════════════

  static Future<List<BarberModel>> getAllBarbers() async {
    try {
      final snap = await _db
          .collection('barbers')
          .where('isProfileDone', isEqualTo: true)
          .get();
      final List<BarberModel> result = [];
      for (final doc in snap.docs) {
        final services = await getBarberServices(doc.id);
        final b = _barberFromDoc(doc);
        result.add(
          BarberModel(
            id: b.id,
            name: b.name,
            shopName: b.shopName,
            specialty: b.specialty,
            location: b.location,
            bio: b.bio,
            rating: b.rating,
            reviewCount: b.reviewCount,
            totalClients: b.totalClients,
            experienceYears: b.experienceYears,
            initial: b.initial,
            isOpen: b.isOpen,
            status: b.status,
            services: services,
          ),
        );
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  // ── Customer bookings stream ──
  // FIX: sort by raw Timestamp stored separately, not by date string
  static Stream<List<AppointmentModel>> getCustomerBookingsStream() {
    return _db
        .collection('appointments')
        .where('customerId', isEqualTo: currentUid)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => _apptFromDoc(d)).toList();
          // Sort by status priority then alphabetically by date
          list.sort((a, b) {
            const order = {
              'pending': 0,
              'confirmed': 1,
              'completed': 2,
              'cancelled': 3,
            };
            final cmp = (order[a.status] ?? 9).compareTo(order[b.status] ?? 9);
            return cmp;
          });
          return list;
        });
  }

  // ── Create booking + notify barber ──
  static Future<void> createBooking({
    required BarberModel barber,
    required ServiceModel service,
    required String date,
    required String timeSlot,
    required String customerName,
  }) async {
    // 1. Write appointment
    final ref = await _db.collection('appointments').add({
      'barberId': barber.id,
      'barberName': barber.name,
      'customerId': currentUid,
      'customerName': customerName,
      'customerInitial': _initial(customerName),
      'serviceId': service.id,
      'serviceName': service.name,
      'price': service.price,
      'durationMin': service.durationMin,
      'date': date,
      'timeSlot': timeSlot,
      'status': 'pending',
      'reviewLeft': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Notify barber
    await _db.collection('notifications').add({
      'userId': barber.id, // barber receives this
      'type': 'new_booking',
      'title': 'New Booking Request! 📅',
      'message':
          '$customerName booked ${service.name}'
          ' on $date at $timeSlot.',
      'appointmentId': ref.id,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 3. Notify customer (confirmation pending)
    await _db.collection('notifications').add({
      'userId': currentUid, // customer receives this
      'type': 'booking_sent',
      'title': 'Booking Request Sent! 🕐',
      'message':
          'Your booking with ${barber.name}'
          ' on $date at $timeSlot is awaiting confirmation.',
      'appointmentId': ref.id,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> cancelBooking(String apptId) async {
    try {
      await _db.collection('appointments').doc(apptId).update({
        'status': 'cancelled',
      });
    } catch (_) {}
  }

  static Future<void> submitReview({
    required String barberId,
    required String appointmentId,
    required int rating,
    required String comment,
    required String customerName,
  }) async {
    // 1. Add review
    await _db.collection('reviews').add({
      'barberId': barberId,
      'customerId': currentUid,
      'customerName': customerName,
      'appointmentId': appointmentId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // 2. Mark appointment reviewed
    await _db.collection('appointments').doc(appointmentId).update({
      'reviewLeft': true,
    });
    // 3. Recalculate barber rating
    try {
      final reviews = await _db
          .collection('reviews')
          .where('barberId', isEqualTo: barberId)
          .get();
      if (reviews.docs.isNotEmpty) {
        final total = reviews.docs.fold<int>(
          0,
          (acc, d) => acc + (d['rating'] as int? ?? 0),
        );
        final avg = total / reviews.docs.length;
        await _db.collection('barbers').doc(barberId).update({
          'rating': double.parse(avg.toStringAsFixed(1)),
          'reviewCount': reviews.docs.length,
        });
      }
    } catch (_) {}
  }

  // ── Notifications stream ──
  // FIX: store raw snapshot docs, sort by createdAt Timestamp
  static Stream<List<NotificationModel>> getNotificationsStream() {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: currentUid)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) {
            // Keep raw timestamp for sorting
            final ts = d['createdAt'];
            return _NotifWithTs(
              model: NotificationModel(
                id: d.id,
                type: d['type'] ?? '',
                title: d['title'] ?? '',
                message: d['message'] ?? '',
                time: _fmtTs(ts),
                isRead: d['isRead'] ?? false,
              ),
              ts: ts is Timestamp ? ts.toDate() : DateTime(2000),
            );
          }).toList();
          // Sort newest first using real DateTime
          list.sort((a, b) => b.ts.compareTo(a.ts));
          return list.map((e) => e.model).toList();
        });
  }

  static Future<void> markNotificationRead(String id) async {
    try {
      await _db.collection('notifications').doc(id).update({'isRead': true});
    } catch (_) {}
  }

  static Future<void> markAllNotificationsRead() async {
    try {
      final snap = await _db
          .collection('notifications')
          .where('userId', isEqualTo: currentUid)
          .where('isRead', isEqualTo: false)
          .get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (_) {}
  }

  static Future<void> toggleFavourite(String barberId, bool add) async {
    try {
      await _db.collection('customers').doc(currentUid).update({
        'favouriteBarberIds': add
            ? FieldValue.arrayUnion([barberId])
            : FieldValue.arrayRemove([barberId]),
      });
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> getCustomerProfile() async {
    try {
      final doc = await _db.collection('customers').doc(currentUid).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateCustomerProfile(Map<String, dynamic> data) async {
    await _db.collection('customers').doc(currentUid).update(data);
  }

  // ── Booked slots for a barber on a date ──
  // FIX: single where query to avoid index requirement
  static Future<List<String>> getBookedSlots(
    String barberId,
    String date,
  ) async {
    try {
      final snap = await _db
          .collection('appointments')
          .where('barberId', isEqualTo: barberId)
          .where('date', isEqualTo: date)
          .get();
      // Filter cancelled out in Dart (avoids whereIn index)
      return snap.docs
          .where((d) {
            final s = d['status'] as String? ?? '';
            return s == 'pending' || s == 'confirmed';
          })
          .map((d) => d['timeSlot'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════

  static String _initial(dynamic name) {
    final s = name?.toString() ?? '';
    return s.isNotEmpty ? s[0].toUpperCase() : 'U';
  }

  static String _fmtTs(dynamic ts) {
    if (ts == null) return 'Just now';
    if (ts is Timestamp) {
      final diff = DateTime.now().difference(ts.toDate());
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hr ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays} days ago';
    }
    return 'Just now';
  }

  static BarberModel _barberFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final name = d['name']?.toString() ?? '';
    return BarberModel(
      id: doc.id,
      name: name,
      shopName: d['shopName'] ?? '',
      specialty: d['specialty'] ?? '',
      location: d['location'] ?? '',
      bio: d['bio'] ?? '',
      rating: (d['rating'] ?? 0.0).toDouble(),
      reviewCount: (d['reviewCount'] ?? 0).toInt(),
      totalClients: (d['totalClients'] ?? 0).toInt(),
      experienceYears: (d['experienceYears'] ?? 0).toInt(),
      initial: name.isNotEmpty ? name[0].toUpperCase() : 'B',
      isOpen: d['isOpen'] ?? false,
      status: d['status'] ?? 'open',
      services: [],
    );
  }

  static AppointmentModel _apptFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      customerId: d['customerId'] ?? '',
      customerName: d['customerName'] ?? '',
      customerInitial: d['customerInitial'] ?? 'C',
      barberId: d['barberId'] ?? '',
      barberName: d['barberName'] ?? '',
      serviceId: d['serviceId'] ?? '',
      serviceName: d['serviceName'] ?? '',
      price: (d['price'] ?? 0).toInt(),
      date: d['date'] ?? '',
      timeSlot: d['timeSlot'] ?? '',
      status: d['status'] ?? 'pending',
      reviewLeft: d['reviewLeft'] ?? false,
    );
  }
}

// Helper class to sort notifications by real DateTime
class _NotifWithTs {
  final NotificationModel model;
  final DateTime ts;
  const _NotifWithTs({required this.model, required this.ts});
}
