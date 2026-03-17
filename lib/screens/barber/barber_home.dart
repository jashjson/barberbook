import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';

class BarberHome extends StatefulWidget {
  const BarberHome({super.key});
  @override
  State<BarberHome> createState() => _BarberHomeState();
}

class _BarberHomeState extends State<BarberHome> {
  BarberModel? _barber;
  String _status = 'open';

  @override
  void initState() {
    super.initState();
    _loadBarber();
  }

  Future<void> _loadBarber() async {
    final b = await FirebaseService.getCurrentBarber();
    if (mounted && b != null) {
      setState(() {
        _barber = b;
        _status = b.status;
      });
    }
  }

  Color get _statusColor {
    if (_status == 'open') return const Color(0xFF1D9E75);
    if (_status == 'busy') return const Color(0xFFE24B4A);
    if (_status == 'break') return const Color(0xFFEF9F27);
    return AppTheme.textGrey;
  }

  String _todayStr() {
    final n = DateTime.now();
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
    return '${dy[n.weekday - 1]}, ${mo[n.month - 1]} ${n.day}';
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
              onTap: _setStatus,
            ),
            const SizedBox(height: 10),
            _StatusTile(
              label: 'Busy',
              sub: 'Currently with a customer',
              color: const Color(0xFFE24B4A),
              icon: Icons.cancel_rounded,
              value: 'busy',
              current: _status,
              onTap: _setStatus,
            ),
            const SizedBox(height: 10),
            _StatusTile(
              label: 'On Break',
              sub: 'Taking a short break',
              color: const Color(0xFFEF9F27),
              icon: Icons.pause_circle_rounded,
              value: 'break',
              current: _status,
              onTap: _setStatus,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setStatus(String s) async {
    Navigator.pop(context);
    setState(() => _status = s);
    await FirebaseService.updateBarberStatus(s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: StreamBuilder<List<AppointmentModel>>(
          stream: FirebaseService.getBarberAppointmentsStream(),
          builder: (context, snap) {
            final appts = snap.data ?? [];
            final confirmed = appts
                .where((a) => a.status == 'confirmed')
                .length;
            final pending = appts.where((a) => a.status == 'pending').length;
            final earnings = appts
                .where((a) => a.status == 'confirmed')
                .fold<int>(0, (acc, a) => acc + a.price);

            return CustomScrollView(
              slivers: [
                // Header
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
                                'Good day,',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textGrey,
                                ),
                              ),
                              Text(
                                '${_barber?.name ?? 'Barber'} ✂️',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppTheme.primary.withAlpha(40),
                          child: Text(
                            _barber?.initial ?? 'B',
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

                // Status card
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
                              color: Colors.white.withAlpha(50),
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
                                  'Status: ${_status[0].toUpperCase()}'
                                  '${_status.substring(1)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  _status == 'open'
                                      ? 'Accepting bookings'
                                      : _status == 'busy'
                                      ? 'With a customer'
                                      : 'On Break',
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

                // Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Upcoming',
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

                // Earnings
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
                              'Expected earnings',
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
                          _barber?.shopName ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Heading
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upcoming Appointments',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          _todayStr(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (snap.connectionState == ConnectionState.waiting)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else if (appts.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 48,
                              color: AppTheme.textGrey.withAlpha(80),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No upcoming appointments',
                              style: TextStyle(color: AppTheme.textGrey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ApptCard(appt: appts[i]),
                      childCount: appts.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
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
  const _ApptCard({required this.appt});

  Color get _color {
    if (appt.status == 'confirmed') return const Color(0xFF1D9E75);
    if (appt.status == 'pending') return const Color(0xFFEF9F27);
    return AppTheme.textGrey;
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
              Column(
                children: [
                  Text(
                    appt.date.length > 6
                        ? appt.date.substring(0, 3)
                        : appt.date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    appt.timeSlot.split(' ')[0],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    appt.timeSlot.contains(' ')
                        ? appt.timeSlot.split(' ')[1]
                        : '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.border,
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withAlpha(30),
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
                  color: _color.withAlpha(25),
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
                    onPressed: () => FirebaseService.updateAppointmentStatus(
                      appt.id,
                      'cancelled',
                    ),
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
                    onPressed: () => FirebaseService.updateAppointmentStatus(
                      appt.id,
                      'confirmed',
                    ),
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
    final sel = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? color.withAlpha(20) : AppTheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? color : AppTheme.border,
            width: sel ? 1.5 : 1,
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
            if (sel) Icon(Icons.check_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
