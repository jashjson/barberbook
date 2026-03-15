import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class _DaySchedule {
  final String day;
  final String short;
  bool isOpen;
  TimeOfDay openTime;
  TimeOfDay closeTime;

  _DaySchedule({
    required this.day,
    required this.short,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
  });
}

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final List<_DaySchedule> _schedule = [
    _DaySchedule(
      day: 'Monday',
      short: 'Mon',
      isOpen: true,
      openTime: const TimeOfDay(hour: 9, minute: 0),
      closeTime: const TimeOfDay(hour: 19, minute: 0),
    ),
    _DaySchedule(
      day: 'Tuesday',
      short: 'Tue',
      isOpen: true,
      openTime: const TimeOfDay(hour: 9, minute: 0),
      closeTime: const TimeOfDay(hour: 19, minute: 0),
    ),
    _DaySchedule(
      day: 'Wednesday',
      short: 'Wed',
      isOpen: true,
      openTime: const TimeOfDay(hour: 9, minute: 0),
      closeTime: const TimeOfDay(hour: 19, minute: 0),
    ),
    _DaySchedule(
      day: 'Thursday',
      short: 'Thu',
      isOpen: true,
      openTime: const TimeOfDay(hour: 9, minute: 0),
      closeTime: const TimeOfDay(hour: 19, minute: 0),
    ),
    _DaySchedule(
      day: 'Friday',
      short: 'Fri',
      isOpen: true,
      openTime: const TimeOfDay(hour: 9, minute: 0),
      closeTime: const TimeOfDay(hour: 20, minute: 0),
    ),
    _DaySchedule(
      day: 'Saturday',
      short: 'Sat',
      isOpen: true,
      openTime: const TimeOfDay(hour: 8, minute: 0),
      closeTime: const TimeOfDay(hour: 20, minute: 0),
    ),
    _DaySchedule(
      day: 'Sunday',
      short: 'Sun',
      isOpen: false,
      openTime: const TimeOfDay(hour: 10, minute: 0),
      closeTime: const TimeOfDay(hour: 17, minute: 0),
    ),
  ];

  int _slotDuration = 30;

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  Future<void> _pickTime(int index, bool isOpenTime) async {
    final current = isOpenTime
        ? _schedule[index].openTime
        : _schedule[index].closeTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _schedule[index].openTime = picked;
        } else {
          _schedule[index].closeTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final openDays = _schedule.where((d) => d.isOpen).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Availability',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Set your working hours',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$openDays days open',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Slot duration
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Slot duration',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  ...[20, 30, 45, 60].map(
                    (min) => GestureDetector(
                      onTap: () => setState(() => _slotDuration = min),
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _slotDuration == min
                              ? AppTheme.primary
                              : AppTheme.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _slotDuration == min
                                ? AppTheme.primary
                                : AppTheme.border,
                          ),
                        ),
                        child: Text(
                          '${min}m',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _slotDuration == min
                                ? Colors.white
                                : AppTheme.textGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Day list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _schedule.length,
                itemBuilder: (_, i) {
                  final day = _schedule[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: day.isOpen
                            ? AppTheme.primary.withValues(alpha: 0.3)
                            : AppTheme.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: day.isOpen
                                    ? AppTheme.primary.withValues(alpha: 0.1)
                                    : AppTheme.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  day.short,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: day.isOpen
                                        ? AppTheme.primary
                                        : AppTheme.textGrey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                day.day,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: day.isOpen
                                      ? AppTheme.textDark
                                      : AppTheme.textGrey,
                                ),
                              ),
                            ),
                            Switch(
                              value: day.isOpen,
                              onChanged: (v) =>
                                  setState(() => _schedule[i].isOpen = v),
                              activeThumbColor: AppTheme.primary,
                              activeTrackColor: AppTheme.primary.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ],
                        ),
                        if (day.isOpen) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppTheme.border),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _TimeTile(
                                  label: 'Opens at',
                                  time: _fmt(day.openTime),
                                  onTap: () => _pickTime(i, true),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: AppTheme.textGrey,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _TimeTile(
                                  label: 'Closes at',
                                  time: _fmt(day.closeTime),
                                  onTap: () => _pickTime(i, false),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Availability saved ✓'),
                    backgroundColor: AppTheme.primary,
                  ),
                ),
                child: const Text('Save Availability'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label, time;
  final VoidCallback onTap;
  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
