import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';

class BookingScreen extends StatefulWidget {
  final BarberModel barber;
  const BookingScreen({super.key, required this.barber});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 0;
  ServiceModel? _selectedService;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;

  List<ServiceModel> get _services =>
      widget.barber.services.where((s) => s.isActive).toList();

  List<String> get _bookedSlots => customerBookings
      .where(
        (b) =>
            b.barberId == widget.barber.id &&
            b.date == _fmtDate(_selectedDate) &&
            b.status != 'cancelled',
      )
      .map((b) => b.timeSlot)
      .toList();

  bool get _canProceed {
    if (_step == 0) return _selectedService != null;
    if (_step == 2) return _selectedSlot != null;
    return true;
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  void _nextStep() {
    if (_step < 3) setState(() => _step++);
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  void _confirmBooking() {
    // Add to customerBookings list
    customerBookings.insert(
      0,
      AppointmentModel(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        customerId: 'cust_001',
        customerName: 'Arun Kumar',
        customerInitial: 'A',
        barberId: widget.barber.id,
        barberName: widget.barber.name,
        serviceId: _selectedService!.id,
        serviceName: _selectedService!.name,
        price: _selectedService!.price,
        date: _fmtDate(_selectedDate),
        timeSlot: _selectedSlot!,
        status: 'pending',
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Booking Sent!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your request with ${widget.barber.name} on ${_fmtDate(_selectedDate)} at $_selectedSlot is pending confirmation.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
            ),
            child: const Text('Go to My Bookings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
            size: 20,
          ),
          onPressed: _step == 0 ? () => Navigator.pop(context) : _prevStep,
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Step indicator ──
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Row(
              children: List.generate(4, (i) {
                final labels = ['Service', 'Date', 'Time', 'Confirm'];
                final done = i < _step;
                final active = i == _step;
                return Expanded(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: done
                                  ? AppTheme.primary
                                  : active
                                  ? AppTheme.secondary
                                  : AppTheme.border,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: done
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        color: active
                                            ? Colors.white
                                            : AppTheme.textGrey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 10,
                              color: active
                                  ? AppTheme.secondary
                                  : AppTheme.textGrey,
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      if (i < 3)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.only(bottom: 18),
                            color: done ? AppTheme.primary : AppTheme.border,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: [
                _serviceStep(),
                _dateStep(),
                _timeStep(),
                _confirmStep(),
              ][_step],
            ),
          ),

          // ── Button ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _canProceed
                  ? (_step == 3 ? _confirmBooking : _nextStep)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
              ),
              child: Text(_step == 3 ? 'Confirm Booking' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 0: Service ──
  Widget _serviceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose a service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.barber.name}\'s services',
          style: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 20),
        ..._services.map((s) {
          final selected = _selectedService?.id == s.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedService = s),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.secondary.withValues(alpha: 0.05)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppTheme.secondary : AppTheme.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.secondary.withValues(alpha: 0.1)
                          : AppTheme.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.content_cut_rounded,
                      color: selected ? AppTheme.secondary : AppTheme.textGrey,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppTheme.secondary
                                : AppTheme.textDark,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          s.durationLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${s.price}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: selected ? AppTheme.secondary : AppTheme.textDark,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.secondary,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Step 1: Date ──
  Widget _dateStep() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose a date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select your preferred date',
          style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 82,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (_, i) {
              final date = now.add(Duration(days: i + 1));
              final selected =
                  _selectedDate.day == date.day &&
                  _selectedDate.month == date.month;
              final isSunday = date.weekday == 7;
              return GestureDetector(
                onTap: isSunday
                    ? null
                    : () => setState(() => _selectedDate = date),
                child: Opacity(
                  opacity: isSunday ? 0.4 : 1,
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.secondary : AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppTheme.secondary : AppTheme.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          days[date.weekday - 1],
                          style: TextStyle(
                            fontSize: 11,
                            color: selected
                                ? Colors.white70
                                : AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: selected ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          months[date.month - 1],
                          style: TextStyle(
                            fontSize: 10,
                            color: selected
                                ? Colors.white70
                                : AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.secondary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.secondary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: AppTheme.secondary,
                size: 16,
              ),
              const SizedBox(width: 10),
              Text(
                'Selected: ${_fmtDate(_selectedDate)}',
                style: const TextStyle(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 2: Time ──
  Widget _timeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose a time slot',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Available slots for ${_fmtDate(_selectedDate)}',
          style: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _Legend(color: AppTheme.surface, label: 'Available'),
            const SizedBox(width: 14),
            _Legend(color: AppTheme.secondary, label: 'Selected'),
            const SizedBox(width: 14),
            _Legend(color: AppTheme.border, label: 'Booked'),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: allTimeSlots.length,
          itemBuilder: (_, i) {
            final slot = allTimeSlots[i];
            final booked = _bookedSlots.contains(slot);
            final sel = _selectedSlot == slot;
            return GestureDetector(
              onTap: booked ? null : () => setState(() => _selectedSlot = slot),
              child: Container(
                decoration: BoxDecoration(
                  color: booked
                      ? AppTheme.background
                      : sel
                      ? AppTheme.secondary
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: booked
                        ? AppTheme.border
                        : sel
                        ? AppTheme.secondary
                        : AppTheme.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    slot,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: booked
                          ? AppTheme.textGrey.withValues(alpha: 0.4)
                          : sel
                          ? Colors.white
                          : AppTheme.textDark,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Step 3: Confirm ──
  Widget _confirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Review your appointment details',
          style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.secondary.withValues(alpha: 0.12),
                    child: Text(
                      widget.barber.initial,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.barber.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        widget.barber.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppTheme.border),
              const SizedBox(height: 16),
              _Row(
                icon: Icons.content_cut_rounded,
                label: 'Service',
                value: _selectedService?.name ?? '',
              ),
              const SizedBox(height: 10),
              _Row(
                icon: Icons.calendar_today_rounded,
                label: 'Date',
                value: _fmtDate(_selectedDate),
              ),
              const SizedBox(height: 10),
              _Row(
                icon: Icons.access_time_rounded,
                label: 'Time',
                value: _selectedSlot ?? '',
              ),
              const SizedBox(height: 10),
              _Row(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value: _selectedService?.durationLabel ?? '',
              ),
              const SizedBox(height: 10),
              _Row(
                icon: Icons.currency_rupee_rounded,
                label: 'Total',
                value: '₹${_selectedService?.price ?? 0}',
                highlight: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEF9F27).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFEF9F27).withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFEF9F27),
                size: 16,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Free cancellation up to 2 hours before the appointment.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFEF9F27),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: AppTheme.border),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppTheme.textGrey),
      ),
    ],
  );
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool highlight;
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 15, color: AppTheme.textGrey),
      const SizedBox(width: 10),
      Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
      ),
      const Spacer(),
      Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: highlight ? AppTheme.secondary : AppTheme.textDark,
        ),
      ),
    ],
  );
}
