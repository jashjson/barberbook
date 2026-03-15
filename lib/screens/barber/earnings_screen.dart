import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _period = 'Today';
  final List<String> _periods = ['Today', 'Yesterday', 'All Time'];

  List<EarningsEntry> get _filtered {
    if (_period == 'Today') {
      return earningsHistory.where((e) => e.date.startsWith('Today')).toList();
    }
    if (_period == 'Yesterday') {
      return earningsHistory
          .where((e) => e.date.startsWith('Yesterday'))
          .toList();
    }
    return earningsHistory;
  }

  int get _total => _filtered.fold(0, (s, e) => s + e.amount);
  int get _count => _filtered.length;
  int get _avg => _count > 0 ? (_total / _count).round() : 0;

  final List<Map<String, dynamic>> _weekBars = [
    {'day': 'Mon', 'amount': '₹700', 'height': 60.0},
    {'day': 'Tue', 'amount': '₹400', 'height': 35.0},
    {'day': 'Wed', 'amount': '₹900', 'height': 78.0},
    {'day': 'Thu', 'amount': '₹550', 'height': 47.0},
    {'day': 'Fri', 'amount': '₹750', 'height': 65.0},
    {'day': 'Sat', 'amount': '₹1100', 'height': 95.0},
    {'day': 'Sun', 'amount': '₹200', 'height': 17.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Earnings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: _periods.map((p) {
                        final active = _period == p;
                        return GestureDetector(
                          onTap: () => setState(() => _period = p),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppTheme.primary
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active
                                    ? AppTheme.primary
                                    : AppTheme.border,
                              ),
                            ),
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: active
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

            // ── Big card ──
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _period,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹$_total',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _Mini(
                          label: 'Appointments',
                          value: '$_count',
                          icon: Icons.calendar_today_rounded,
                        ),
                        const SizedBox(width: 24),
                        _Mini(
                          label: 'Avg per visit',
                          value: '₹$_avg',
                          icon: Icons.trending_up_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Weekly bar chart ──
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This week',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _weekBars
                          .map(
                            (d) => _Bar(
                              day: d['day'],
                              height: d['height'],
                              amount: d['amount'],
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Transactions heading ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  'Transactions · $_period',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),

            // ── Transactions list ──
            _filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: AppTheme.textGrey.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No transactions',
                              style: TextStyle(color: AppTheme.textGrey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((_, i) {
                      final e = _filtered[i];
                      return Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppTheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              child: Text(
                                e.customerInitial,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.customerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${e.service} · ${e.date}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '+ ₹${e.amount}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }, childCount: _filtered.length),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Mini({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: Colors.white70, size: 15),
      const SizedBox(width: 6),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    ],
  );
}

class _Bar extends StatelessWidget {
  final String day, amount;
  final double height;
  const _Bar({required this.day, required this.height, required this.amount});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        amount,
        style: const TextStyle(fontSize: 9, color: AppTheme.primary),
      ),
      const SizedBox(height: 4),
      Container(
        width: 28,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      const SizedBox(height: 6),
      Text(day, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
    ],
  );
}
