import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});
  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final List<_Day> _schedule = [
    _Day('Monday'),
    _Day('Tuesday'),
    _Day('Wednesday'),
    _Day('Thursday'),
    _Day('Friday'),
    _Day('Saturday'),
    _Day('Sunday', isOpen: false),
  ];
  int _slotDuration = 30;
  bool _loading = true;
  bool _saving = false;
  final List<int> _durations = [20, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final snap = await FirebaseFirestore.instance
          .collection('barbers')
          .doc(uid)
          .collection('availability')
          .get();
      for (final doc in snap.docs) {
        final idx = _schedule.indexWhere((d) => d.day == doc['day']);
        if (idx != -1) {
          setState(() {
            _schedule[idx].isOpen = doc['isOpen'] ?? true;
            _schedule[idx].openTime = doc['openTime'] ?? '9:00 AM';
            _schedule[idx].closeTime = doc['closeTime'] ?? '6:00 PM';
            _slotDuration = doc['slotDuration'] ?? 30;
          });
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final batch = FirebaseFirestore.instance.batch();
      for (final day in _schedule) {
        final ref = FirebaseFirestore.instance
            .collection('barbers')
            .doc(uid)
            .collection('availability')
            .doc(day.day);
        batch.set(ref, {
          'day': day.day,
          'isOpen': day.isOpen,
          'openTime': day.openTime,
          'closeTime': day.closeTime,
          'slotDuration': _slotDuration,
        });
      }
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability saved ✓'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) {
      setState(() => _saving = false);
    }
  }

  Future<void> _pickTime(int idx, bool isOpenTime) async {
    final current = isOpenTime
        ? _schedule[idx].openTime
        : _schedule[idx].closeTime;
    final parts = current.split(':');
    final hourRaw = int.tryParse(parts[0]) ?? 9;
    final isPm = current.contains('PM');
    final hour24 = isPm && hourRaw != 12
        ? hourRaw + 12
        : !isPm && hourRaw == 12
        ? 0
        : hourRaw;
    final minStr = parts.length > 1
        ? parts[1].replaceAll(RegExp(r'[^0-9]'), '')
        : '00';
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour24, minute: int.tryParse(minStr) ?? 0),
    );
    if (picked != null && mounted) {
      final pm = picked.hour >= 12 ? 'PM' : 'AM';
      final h = picked.hour > 12
          ? picked.hour - 12
          : picked.hour == 0
          ? 12
          : picked.hour;
      final m = picked.minute.toString().padLeft(2, '0');
      setState(() {
        if (isOpenTime) {
          _schedule[idx].openTime = '$h:$m $pm';
        } else {
          _schedule[idx].closeTime = '$h:$m $pm';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Availability',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded, size: 16),
                            label: Text(_saving ? 'Saving...' : 'Save'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(90, 38),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Slot duration
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Slot duration',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: _durations.map((d) {
                              final sel = _slotDuration == d;
                              return GestureDetector(
                                onTap: () => setState(() => _slotDuration = d),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? AppTheme.primary
                                        : AppTheme.background,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: sel
                                          ? AppTheme.primary
                                          : AppTheme.border,
                                    ),
                                  ),
                                  child: Text(
                                    '$d min',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: sel
                                          ? Colors.white
                                          : AppTheme.textGrey,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Text(
                        'Weekly schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ),

                  SliverList(
                    delegate: SliverChildBuilderDelegate((_, i) {
                      final day = _schedule[i];
                      return Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: day.isOpen
                                ? AppTheme.primary.withValues(alpha: 0.2)
                                : AppTheme.border,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    day.day,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: day.isOpen
                                          ? AppTheme.textDark
                                          : AppTheme.textGrey,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: day.isOpen,
                                  onChanged: (v) =>
                                      setState(() => day.isOpen = v),
                                  activeThumbColor: AppTheme.primary,
                                  activeTrackColor: AppTheme.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ],
                            ),
                            if (day.isOpen) ...[
                              const Divider(height: 1, color: AppTheme.border),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _TimeBtn(
                                      label: 'Opens',
                                      time: day.openTime,
                                      onTap: () => _pickTime(i, true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppTheme.textGrey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _TimeBtn(
                                      label: 'Closes',
                                      time: day.closeTime,
                                      onTap: () => _pickTime(i, false),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Closed',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }, childCount: _schedule.length),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
      ),
    );
  }
}

class _Day {
  final String day;
  bool isOpen;
  String openTime = '9:00 AM';
  String closeTime = '6:00 PM';
  _Day(this.day, {this.isOpen = true});
}

class _TimeBtn extends StatelessWidget {
  final String label, time;
  final VoidCallback onTap;
  const _TimeBtn({
    required this.label,
    required this.time,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textGrey),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
