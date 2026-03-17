import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import 'review_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: StreamBuilder<List<AppointmentModel>>(
          stream: FirebaseService.getCustomerBookingsStream(),
          builder: (context, snap) {
            final all = snap.data ?? [];
            final upcoming = all
                .where((b) => ['pending', 'confirmed'].contains(b.status))
                .toList();
            final completed = all
                .where((b) => b.status == 'completed')
                .toList();
            final cancelled = all
                .where((b) => b.status == 'cancelled')
                .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'My Bookings',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${all.length} total',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: TabBar(
                    controller: _tab,
                    indicator: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.textGrey,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    tabs: [
                      Tab(text: 'Upcoming (${upcoming.length})'),
                      Tab(text: 'Done (${completed.length})'),
                      Tab(text: 'Cancelled (${cancelled.length})'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (snap.connectionState == ConnectionState.waiting)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Expanded(
                    child: TabBarView(
                      controller: _tab,
                      children: [
                        _List(
                          bookings: upcoming,
                          showCancel: true,
                          showReview: false,
                        ),
                        _List(
                          bookings: completed,
                          showCancel: false,
                          showReview: true,
                        ),
                        _List(
                          bookings: cancelled,
                          showCancel: false,
                          showReview: false,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  final List<AppointmentModel> bookings;
  final bool showCancel, showReview;
  const _List({
    required this.bookings,
    required this.showCancel,
    required this.showReview,
  });
  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 48,
              color: AppTheme.textGrey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              'No bookings here',
              style: TextStyle(color: AppTheme.textGrey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: bookings.length,
      itemBuilder: (_, i) => _Card(
        booking: bookings[i],
        showCancel: showCancel,
        showReview: showReview,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final AppointmentModel booking;
  final bool showCancel, showReview;
  const _Card({
    required this.booking,
    required this.showCancel,
    required this.showReview,
  });

  Color get _statusColor {
    if (booking.status == 'confirmed') return AppTheme.primary;
    if (booking.status == 'pending') return const Color(0xFFEF9F27);
    if (booking.status == 'completed') return AppTheme.primary;
    if (booking.status == 'cancelled') return const Color(0xFFE24B4A);
    return AppTheme.textGrey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.secondary.withValues(alpha: 0.12),
                child: Text(
                  booking.customerInitial,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.barberName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      booking.serviceName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status[0].toUpperCase() + booking.status.substring(1),
                  style: TextStyle(
                    fontSize: 11,
                    color: _statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: AppTheme.textGrey,
              ),
              const SizedBox(width: 5),
              Text(
                booking.date,
                style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.access_time_rounded,
                size: 13,
                color: AppTheme.textGrey,
              ),
              const SizedBox(width: 5),
              Text(
                booking.timeSlot,
                style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
              ),
              const Spacer(),
              Text(
                '₹${booking.price}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          if (showCancel) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => FirebaseService.cancelBooking(booking.id),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      foregroundColor: const Color(0xFFE24B4A),
                      side: const BorderSide(color: Color(0xFFE24B4A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reschedule coming soon')),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      backgroundColor: AppTheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Reschedule'),
                  ),
                ),
              ],
            ),
          ],
          if (showReview && !booking.reviewLeft) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewScreen(appointment: booking),
                  ),
                ),
                icon: const Icon(Icons.star_border_rounded, size: 16),
                label: const Text('Leave a Review'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  foregroundColor: AppTheme.secondary,
                  side: BorderSide(
                    color: AppTheme.secondary.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
          if (showReview && booking.reviewLeft)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppTheme.primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Review submitted',
                    style: TextStyle(fontSize: 12, color: AppTheme.primary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
