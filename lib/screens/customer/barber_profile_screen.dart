import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';
import 'booking_screen.dart';

class BarberProfileScreen extends StatefulWidget {
  final BarberModel barber;
  const BarberProfileScreen({super.key, required this.barber});

  @override
  State<BarberProfileScreen> createState() => _BarberProfileScreenState();
}

class _BarberProfileScreenState extends State<BarberProfileScreen> {
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = favouriteBarberIds.contains(widget.barber.id);
  }

  void _toggleFav() {
    setState(() {
      _isFav = !_isFav;
      if (_isFav) {
        favouriteBarberIds.add(widget.barber.id);
      } else {
        favouriteBarberIds.remove(widget.barber.id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFav ? 'Added to favourites ♡' : 'Removed from favourites',
        ),
        backgroundColor: AppTheme.secondary,
      ),
    );
  }

  List<ReviewModel> get _reviews =>
      barberReviews.where((r) => r.barberId == widget.barber.id).toList();

  List<ServiceModel> get _services =>
      widget.barber.services.where((s) => s.isActive).toList();

  @override
  Widget build(BuildContext context) {
    final b = widget.barber;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──
          SliverAppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textDark,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              b.shopName,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isFav ? const Color(0xFFE24B4A) : AppTheme.textGrey,
                ),
                onPressed: _toggleFav,
              ),
            ],
          ),

          // ── Profile header ──
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppTheme.secondary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          b.initial,
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: b.isOpen
                                ? const Color(0xFF1D9E75)
                                : AppTheme.textGrey,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    b.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    b.specialty,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppTheme.textGrey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        b.location,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: b.isOpen
                          ? const Color(0xFF1D9E75).withValues(alpha: 0.1)
                          : AppTheme.textGrey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      b.isOpen ? '● Open now' : '● Currently closed',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: b.isOpen
                            ? const Color(0xFF1D9E75)
                            : AppTheme.textGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(
                        value: '${b.rating}',
                        label: 'Rating',
                        icon: Icons.star_rounded,
                        color: const Color(0xFFEF9F27),
                      ),
                      Container(width: 1, height: 32, color: AppTheme.border),
                      _Stat(
                        value: '${b.reviewCount}',
                        label: 'Reviews',
                        icon: Icons.chat_bubble_outline_rounded,
                        color: AppTheme.secondary,
                      ),
                      Container(width: 1, height: 32, color: AppTheme.border),
                      _Stat(
                        value: '${b.experienceYears} yrs',
                        label: 'Exp',
                        icon: Icons.workspace_premium_rounded,
                        color: AppTheme.primary,
                      ),
                      Container(width: 1, height: 32, color: AppTheme.border),
                      _Stat(
                        value: '${b.totalClients}',
                        label: 'Clients',
                        icon: Icons.people_outline_rounded,
                        color: const Color(0xFF7F77DD),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Bio ──
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    b.bio,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGrey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Services (from THIS barber's data) ──
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Services & Pricing',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Text(
                        '${_services.length} services',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ..._services.map(
                    (s) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.content_cut_rounded,
                              color: AppTheme.secondary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                    fontSize: 14,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Reviews ──
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Reviews',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFEF9F27),
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${b.rating} · ${b.reviewCount} reviews',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _reviews.isEmpty
                      ? const Text(
                          'No reviews yet',
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 13,
                          ),
                        )
                      : Column(
                          children: _reviews
                              .map(
                                (r) => Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: AppTheme.secondary
                                                .withValues(alpha: 0.12),
                                            child: Text(
                                              r.customerInitial,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.secondary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              r.customerName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textDark,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: List.generate(
                                              5,
                                              (i) => Icon(
                                                Icons.star_rounded,
                                                size: 12,
                                                color: i < r.rating
                                                    ? const Color(0xFFEF9F27)
                                                    : AppTheme.border,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        r.comment,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textGrey,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        r.date,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── Book button ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: b.isOpen
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookingScreen(barber: b)),
                )
              : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
          child: Text(b.isOpen ? 'Book Appointment' : 'Currently Closed'),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(height: 3),
      Text(
        value,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppTheme.textGrey),
      ),
    ],
  );
}
