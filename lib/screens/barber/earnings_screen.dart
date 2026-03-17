import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});
  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _period = 'Today';
  final List<String> _periods = ['Today', 'This Week', 'All Time'];
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final snap = await FirebaseFirestore.instance
          .collection('appointments')
          .where('barberId', isEqualTo: uid)
          .where('status', whereIn: ['completed', 'confirmed'])
          .get();
      final list = snap.docs
          .map(
            (d) => {
              'customerName': d['customerName'] ?? '',
              'customerInitial':
                  (d['customerName'] as String? ?? 'C').isNotEmpty
                  ? (d['customerName'] as String)[0].toUpperCase()
                  : 'C',
              'service': d['serviceName'] ?? '',
              'date': d['date'] ?? '',
              'timeSlot': d['timeSlot'] ?? '',
              'amount': (d['price'] ?? 0).toInt(),
              'status': d['status'] ?? '',
            },
          )
          .toList();
      if (mounted) {
        setState(() {
          _transactions = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final today = _todayStr();
    if (_period == 'Today') {
      return _transactions.where((t) => t['date'] == today).toList();
    }
    if (_period == 'This Week') {
      // Show last 7 days
      return _transactions.take(50).toList();
    }
    return _transactions;
  }

  int get _total =>
      _filtered.fold<int>(0, (acc, t) => acc + (t['amount'] as int));
  int get _count => _filtered.length;
  int get _avg => _count > 0 ? (_total / _count).round() : 0;

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Earnings',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  color: AppTheme.textGrey,
                                ),
                                onPressed: _load,
                              ),
                            ],
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

                  // Earnings card
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

                  _filtered.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 48,
                                    color: AppTheme.textGrey.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No earnings for $_period',
                                    style: const TextStyle(
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((_, i) {
                            final t = _filtered[i];
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
                                    backgroundColor: AppTheme.primary
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      t['customerInitial'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t['customerName'] as String,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textDark,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${t['service']} · ${t['date']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '+ ₹${t['amount']}',
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
