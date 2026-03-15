import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';

class BarberHome extends StatefulWidget {
  const BarberHome({super.key});

  @override
  State<BarberHome> createState() => _BarberHomeState();
}

class _BarberHomeState extends State<BarberHome> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = currentBarber.status;
  }

  List<AppointmentModel> get _todayAppts =>
      barberAppointments.where((a) => a.date == 'Today').toList();

  Color get _statusColor {
    switch (_status) {
      case 'open':
        return const Color(0xFF1D9E75);
      case 'busy':
        return const Color(0xFFE24B4A);
      case 'break':
        return const Color(0xFFEF9F27);
      default:
        return AppTheme.textGrey;
    }
  }

  String get _statusLabel {
    switch (_status) {
      case 'open':
        return 'Open — Accepting bookings';
      case 'busy':
        return 'Busy — With a customer';
      case 'break':
        return 'On Break';
      default:
        return 'Open';
    }
  }

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set your status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _StatusTile(
              label: 'Open',
              sub: 'Accepting new bookings',
              color: const Color(0xFF1D9E75),
              icon: Icons.check_circle_rounded,
              value: 'open',
              current: _status,
              onTap: (v) {
                setState(() => _status = v);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _StatusTile(
              label: 'Busy',
              sub: 'Currently with a customer',
              color: const Color(0xFFE24B4A),
              icon: Icons.cancel_rounded,
              value: 'busy',
              current: _status,
              onTap: (v) {
                setState(() => _status = v);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _StatusTile(
              label: 'On Break',
              sub: 'Taking a short break',
              color: const Color(0xFFEF9F27),
              icon: Icons.pause_circle_rounded,
              value: 'break',
              current: _status,
              onTap: (v) {
                setState(() => _status = v);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formattedDate() {
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
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  void _updateStatus(String id, String newStatus) {
    final idx = barberAppointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      setState(() {
        barberAppointments[idx] = barberAppointments[idx].copyWith(
          status: newStatus,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appts = _todayAppts;
    final confirmed = appts.where((a) => a.status == 'confirmed').length;
    final pending = appts.where((a) => a.status == 'pending').length;
    final earnings = appts
        .where((a) => a.status != 'cancelled')
        .fold(0, (s, a) => s + a.price);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Good morning,',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textGrey,
                            ),
                          ),
                          Text(
                            '${currentBarber.name} ✂️',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppTheme.textDark,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                      child: Text(
                        currentBarber.initial,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Status card ──
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: _showStatusPicker,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.circle,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${_status[0].toUpperCase()}${_status.substring(1)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              _statusLabel,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Stats ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Today',
                        value: '${appts.length}',
                        sub: 'appointments',
                        icon: Icons.calendar_today_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Confirmed',
                        value: '$confirmed',
                        sub: 'confirmed',
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF1D9E75),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Pending',
                        value: '$pending',
                        sub: 'pending',
                        icon: Icons.hourglass_empty_rounded,
                        color: const Color(0xFFEF9F27),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Earnings today ──
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee_rounded,
                      color: AppTheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's earnings",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        Text(
                          '₹$earnings',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      currentBarber.shopName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Schedule heading ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Schedule",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      _formattedDate(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Appointment list ──
            appts.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
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
                              'No appointments today',
                              style: TextStyle(color: AppTheme.textGrey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) =>
                          _ApptCard(appt: appts[i], onUpdate: _updateStatus),
                      childCount: appts.length,
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          sub,
          style: const TextStyle(fontSize: 10, color: AppTheme.textGrey),
        ),
      ],
    ),
  );
}

class _ApptCard extends StatelessWidget {
  final AppointmentModel appt;
  final void Function(String, String) onUpdate;
  const _ApptCard({required this.appt, required this.onUpdate});

  Color get _color {
    switch (appt.status) {
      case 'confirmed':
        return const Color(0xFF1D9E75);
      case 'pending':
        return const Color(0xFFEF9F27);
      case 'cancelled':
        return const Color(0xFFE24B4A);
      default:
        return AppTheme.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appt.timeSlot.split(' ')[0],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      appt.timeSlot.split(' ')[1],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.border,
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                child: Text(
                  appt.customerInitial,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appt.customerName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${appt.serviceName} · ₹${appt.price}',
                      style: const TextStyle(
                        fontSize: 11,
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
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appt.status[0].toUpperCase() + appt.status.substring(1),
                  style: TextStyle(
                    fontSize: 11,
                    color: _color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (appt.status == 'pending') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onUpdate(appt.id, 'cancelled'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      foregroundColor: const Color(0xFFE24B4A),
                      side: const BorderSide(color: Color(0xFFE24B4A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onUpdate(appt.id, 'confirmed'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String label, sub, value, current;
  final Color color;
  final IconData icon;
  final ValueChanged<String> onTap;
  const _StatusTile({
    required this.label,
    required this.sub,
    required this.value,
    required this.current,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.07) : AppTheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
