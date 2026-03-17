import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';

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
  List<String> _bookedSlots = [];
  bool _loading = false;
  String _customerName = '';

  static const List<String> _allSlots = [
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM',
    '5:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final profile = await FirebaseService.getCustomerProfile();
    if (mounted) {
      setState(() => _customerName = profile?['name'] ?? 'Customer');
    }
  }

  String _fmt(DateTime d) {
    const mo = [
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
    const dy = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${dy[d.weekday - 1]}, ${mo[d.month - 1]} ${d.day}';
  }

  Future<void> _loadSlots() async {
    final slots = await FirebaseService.getBookedSlots(
      widget.barber.id,
      _fmt(_selectedDate),
    );
    if (mounted) {
      setState(() => _bookedSlots = slots);
    }
  }

  bool get _canProceed {
    if (_step == 0) return _selectedService != null;
    if (_step == 2) return _selectedSlot != null;
    return true;
  }

  void _next() {
    if (_step == 1) {
      _loadSlots();
    }
    if (_step < 3) {
      setState(() => _step++);
    }
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      await FirebaseService.createBooking(
        barber: widget.barber,
        service: _selectedService!,
        date: _fmt(_selectedDate),
        timeSlot: _selectedSlot!,
        customerName: _customerName,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                'Your request with ${widget.barber.name} on '
                '${_fmt(_selectedDate)} at $_selectedSlot '
                'is pending confirmation.',
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
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
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
          onPressed: _step == 0
              ? () => Navigator.pop(context)
              : () => setState(() => _step--),
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
          // Steps
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
              onPressed: _canProceed && !_loading
                  ? (_step == 3 ? _confirm : _next)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
              ),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(_step == 3 ? 'Confirm Booking' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

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
        const SizedBox(height: 20),
        if (widget.barber.services.isEmpty)
          const Text(
            'No services available.',
            style: TextStyle(color: AppTheme.textGrey),
          )
        else
          ...widget.barber.services.map((s) {
            final sel = _selectedService?.id == s.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedService = s),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.secondary.withValues(alpha: 0.05)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? AppTheme.secondary : AppTheme.border,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppTheme.secondary.withValues(alpha: 0.1)
                            : AppTheme.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.content_cut_rounded,
                        color: sel ? AppTheme.secondary : AppTheme.textGrey,
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
                              color: sel
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
                        color: sel ? AppTheme.secondary : AppTheme.textDark,
                      ),
                    ),
                    if (sel) ...[
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

  Widget _dateStep() {
    const mo = [
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
    const dy = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
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
        const SizedBox(height: 20),
        SizedBox(
          height: 82,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (_, i) {
              final date = now.add(Duration(days: i + 1));
              final sel =
                  _selectedDate.day == date.day &&
                  _selectedDate.month == date.month;
              final sun = date.weekday == 7;
              return GestureDetector(
                onTap: sun ? null : () => setState(() => _selectedDate = date),
                child: Opacity(
                  opacity: sun ? 0.4 : 1,
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.secondary : AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel ? AppTheme.secondary : AppTheme.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dy[date.weekday - 1],
                          style: TextStyle(
                            fontSize: 11,
                            color: sel ? Colors.white70 : AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: sel ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mo[date.month - 1],
                          style: TextStyle(
                            fontSize: 10,
                            color: sel ? Colors.white70 : AppTheme.textGrey,
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
                'Selected: ${_fmt(_selectedDate)}',
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
          'Available on ${_fmt(_selectedDate)}',
          style: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 14),
        // Legend
        Row(
          children: [
            _Legend(color: AppTheme.surface, label: 'Available'),
            const SizedBox(width: 14),
            _Legend(color: AppTheme.secondary, label: 'Selected'),
            const SizedBox(width: 14),
            _Legend(color: AppTheme.background, label: 'Booked'),
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
          itemCount: _allSlots.length,
          itemBuilder: (_, i) {
            final slot = _allSlots[i];
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
                value: _fmt(_selectedDate),
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
                  'Free cancellation up to 2 hours before.',
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
