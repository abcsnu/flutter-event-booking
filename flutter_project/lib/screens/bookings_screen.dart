// lib/screens/bookings_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/bookings_state.dart';
import '../data/event_model.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<Event> _upcomingBookings = [];
  List<Event> _pastBookings = [];
  bool _showPastEvents = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    bookingsNotifier.addListener(_categorizeBookings);
    _categorizeBookings();
  }

  @override
  void dispose() {
    bookingsNotifier.removeListener(_categorizeBookings);
    super.dispose();
  }

  void _categorizeBookings() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final bookedEventIds = bookingsNotifier.value;
    if (bookedEventIds.isEmpty) {
      if (mounted) {
        setState(() {
          _upcomingBookings = [];
          _pastBookings = [];
          _isLoading = false;
        });
      }
      return;
    }

    final eventsQuery = await FirebaseFirestore.instance
        .collection('events')
        .where(FieldPath.documentId, whereIn: bookedEventIds)
        .get();

    final allBookedEvents = eventsQuery.docs.map((doc) {
      final data = doc.data();
      return Event(
        id: doc.id,
        title: data['title'] ?? 'No Title',
        date: data['date'] ?? '',
        location: data['location'] ?? 'No Location',
        availableSeats: data['availableSeats'] ?? 0,
      );
    }).toList();

    final now = DateTime.now();

    final upcoming = allBookedEvents.where((event) {
      final eventDate = _parseEventDate(event.date);
      return eventDate == null || eventDate.isAfter(now);
    }).toList();

    final past = allBookedEvents.where((event) {
      final eventDate = _parseEventDate(event.date);
      return eventDate != null && eventDate.isBefore(now);
    }).toList();

    if (mounted) {
      setState(() {
        _upcomingBookings = upcoming;
        _pastBookings = past;
        _isLoading = false;
      });
    }
  }

  DateTime? _parseEventDate(String value) {
    for (final format in [
      DateFormat('dd/MM/yyyy HH:mm'),
      DateFormat('d/M/yyyy'),
    ]) {
      try {
        return format.parseStrict(value);
      } on FormatException {
        // Try the next date format to support older event documents.
      }
    }
    return null;
  }

  Widget _buildEmptyBookings(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 70,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'لا توجد حجوزات نشطة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'استعرض الفعاليات المتاحة وقم بالحجز لحضور الفعاليات القادمة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.explore_outlined),
              label: const Text(
                'استعرض الفعاليات',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D8F62),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                shadowColor: const Color(0xFF2D8F62).withAlpha(77),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsHeader(int upcomingCount, int pastCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [const Color(0xFF2D8F62), const Color(0xFF1E5B3D)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حجوزاتي',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'إدارة جميع حجوزاتك في مكان واحد',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha(230),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bookmark_added_rounded,
                  color: Color(0xFF2D8F62),
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                count: upcomingCount,
                label: 'قادمة',
                color: Colors.white,
                icon: Icons.upcoming_outlined,
              ),
              _buildStatCard(
                count: pastCount,
                label: 'منتهية',
                color: Colors.white.withAlpha(204),
                icon: Icons.history_outlined,
              ),
              _buildStatCard(
                count: upcomingCount + pastCount,
                label: 'إجمالي',
                color: Colors.white.withAlpha(230),
                icon: Icons.summarize_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required int count,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withAlpha(230)),
        ),
      ],
    );
  }

  Widget _buildBookingItem(BuildContext context, Event event, int index) {
    final isPast = _pastBookings.contains(event);
    final bookingId = event.id.length > 8 ? event.id.substring(0, 8) : event.id;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isPast ? Colors.grey : const Color(0xFF2D8F62),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isPast
                          ? Colors.grey.shade200
                          : const Color(0xFF2D8F62).withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isPast
                              ? Colors.grey.shade600
                              : const Color(0xFF2D8F62),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isPast
                                      ? Colors.grey.shade600
                                      : Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isPast)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'منتهية',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              event.date,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              event.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildDetailBadge(
                    icon: Icons.confirmation_number_outlined,
                    text: 'رقم الحجز: $bookingId',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  if (!isPast)
                    _buildDetailBadge(
                      icon: Icons.chair_outlined,
                      text: 'المقعد: ${event.availableSeats + 1}',
                      color: Colors.green,
                    ),
                ],
              ),
              if (!isPast) const SizedBox(height: 16),
              if (!isPast)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEventDetails(context, event),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('تفاصيل الفاعلية'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showCancelDialog(context, event),
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('إلغاء الحجز'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(BuildContext context, Event event) {
    Navigator.pushNamed(context, '/details', arguments: event.id);
  }

  void _showCancelDialog(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 12),
                const Text(
                  'تأكيد إلغاء الحجز',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'هل أنت متأكد من رغبتك في إلغاء حجز الفاعلية التالية؟',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.date,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('إلغاء', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      cancelBooking(event.id);
                      Navigator.of(ctx).pop();
                      _showCancellationSuccess(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'تأكيد الإلغاء',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCancellationSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(child: Text('تم إلغاء الحجز بنجاح')),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'حجوزاتي',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'رجوع',
        ),
        elevation: 0,
        actions: [
          if (_pastBookings.isNotEmpty)
            IconButton(
              icon: Icon(
                _showPastEvents
                    ? Icons.upcoming_outlined
                    : Icons.history_outlined,
              ),
              onPressed: () {
                setState(() {
                  _showPastEvents = !_showPastEvents;
                });
              },
              tooltip: _showPastEvents ? 'عرض القادمة' : 'عرض المنتهية',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingsNotifier.value.isEmpty
          ? _buildEmptyBookings(context)
          : Builder(
              builder: (context) {
                final displayEvents = _showPastEvents
                    ? _pastBookings
                    : _upcomingBookings;
                final displayCount = displayEvents.length;

                if (displayCount == 0 && _showPastEvents) {
                  return _buildNoPastBookings();
                }

                return Column(
                  children: [
                    _buildBookingsHeader(
                      _upcomingBookings.length,
                      _pastBookings.length,
                    ),
                    if (_pastBookings.isNotEmpty &&
                        _upcomingBookings.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showPastEvents = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: !_showPastEvents
                                      ? const Color(0xFF2D8F62)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: !_showPastEvents
                                        ? const Color(0xFF2D8F62)
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  'القادمة (${_upcomingBookings.length})',
                                  style: TextStyle(
                                    color: !_showPastEvents
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showPastEvents = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _showPastEvents
                                      ? const Color(0xFF2D8F62)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _showPastEvents
                                        ? const Color(0xFF2D8F62)
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  'المنتهية (${_pastBookings.length})',
                                  style: TextStyle(
                                    color: _showPastEvents
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: displayCount,
                        itemBuilder: (context, index) {
                          final event = displayEvents[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(
                              milliseconds: 300 + (index * 100),
                            ),
                            curve: Curves.easeOutQuart,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: _buildBookingItem(context, event, index),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildNoPastBookings() {
    return Column(
      children: [
        _buildBookingsHeader(_upcomingBookings.length, _pastBookings.length),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_toggle_off_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 20),
                Text(
                  'لا توجد حجوزات منتهية',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'جميع حجوزاتك الحالية هي فعاليات قادمة',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
