import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<AppointmentModel> _filtered(String status) =>
      barberAppointments.where((a) => a.status == status).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateStatus(String id, String newStatus) {
    final idx = barberAppointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      setState(() {
        barberAppointments[idx] = barberAppointments[idx].copyWith(status: newStatus);
      });
    }
    final msg = newStatus == 'confirmed' ? 'Appointment confirmed ✓'
               : newStatus == 'cancelled' ? 'Appointment cancelled'
               : 'Marked as completed ✓';
    final color = newStatus == 'cancelled' ? const Color(0xFFE24B4A) : AppTheme.primary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Row(children: [
              const Expanded(child: Text('Appointments',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${barberAppointments.length} total',
                    style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),

          // ── Tabs ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textGrey,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
              tabs: [
                Tab(text: 'Pending\n(${_filtered('pending').length})'),
                Tab(text: 'Confirmed\n(${_filtered('confirmed').length})'),
                Tab(text: 'Done\n(${_filtered('completed').length})'),
                Tab(text: 'Cancelled\n(${_filtered('cancelled').length})'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ApptList(appointments: _filtered('pending'),   onUpdate: _updateStatus, showConfirm: true,  showComplete: false),
                _ApptList(appointments: _filtered('confirmed'), onUpdate: _updateStatus, showConfirm: false, showComplete: true),
                _ApptList(appointments: _filtered('completed'), onUpdate: _updateStatus, showConfirm: false, showComplete: false),
                _ApptList(appointments: _filtered('cancelled'), onUpdate: _updateStatus, showConfirm: false, showComplete: false),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ApptList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final void Function(String, String) onUpdate;
  final bool showConfirm, showComplete;
  const _ApptList({required this.appointments, required this.onUpdate, required this.showConfirm, required this.showComplete});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.calendar_today_rounded, size: 48, color: AppTheme.textGrey.withValues(alpha: 0.3)),
        const SizedBox(height: 12),
        const Text('No appointments', style: TextStyle(color: AppTheme.textGrey)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: appointments.length,
      itemBuilder: (_, i) => _DetailCard(appt: appointments[i], onUpdate: onUpdate, showConfirm: showConfirm, showComplete: showComplete),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final AppointmentModel appt;
  final void Function(String, String) onUpdate;
  final bool showConfirm, showComplete;
  const _DetailCard({required this.appt, required this.onUpdate, required this.showConfirm, required this.showComplete});

  Color get _statusColor {
    switch (appt.status) {
      case 'confirmed':  return const Color(0xFF1D9E75);
      case 'pending':    return const Color(0xFFEF9F27);
      case 'cancelled':  return const Color(0xFFE24B4A);
      case 'completed':  return AppTheme.primary;
      default:           return AppTheme.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 22, backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              child: Text(appt.customerInitial, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(appt.customerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(appt.status[0].toUpperCase() + appt.status.substring(1),
                style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppTheme.border),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.content_cut_rounded, size: 14, color: AppTheme.textGrey),
          const SizedBox(width: 6),
          Expanded(child: Text(appt.serviceName, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey))),
          Text('₹${appt.price}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primary)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textGrey),
          const SizedBox(width: 6),
          Text('${appt.date}  ·  ${appt.timeSlot}', style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
        ]),
        if (showConfirm || showComplete) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => onUpdate(appt.id, 'cancelled'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38), foregroundColor: const Color(0xFFE24B4A), side: const BorderSide(color: Color(0xFFE24B4A)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Cancel', style: TextStyle(fontSize: 13)),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () => onUpdate(appt.id, showConfirm ? 'confirmed' : 'completed'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(showConfirm ? 'Confirm' : 'Mark Done', style: const TextStyle(fontSize: 13)),
            )),
          ]),
        ],
      ]),
    );
  }
}