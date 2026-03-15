import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';
import 'barber_profile_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filter = 'All';
  final List<String> _filters = ['All', 'Open Now', 'Top Rated', 'Nearby'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BarberModel> get _filtered {
    var list = List<BarberModel>.from(allBarbers);
    if (_filter == 'Open Now') {
      list = list.where((b) => b.isOpen).toList();
    }
    if (_filter == 'Top Rated') {
      list = list.where((b) => b.rating >= 4.7).toList();
    }
    if (_query.isNotEmpty) {
      list = list
          .where(
            (b) =>
                b.name.toLowerCase().contains(_query.toLowerCase()) ||
                b.specialty.toLowerCase().contains(_query.toLowerCase()) ||
                b.shopName.toLowerCase().contains(_query.toLowerCase()),
          )
          .toList();
    }
    return list;
  }

  void _toggleFav(String id) {
    setState(() {
      if (favouriteBarberIds.contains(id)) {
        favouriteBarberIds.remove(id);
      } else {
        favouriteBarberIds.add(id);
      }
    });
  }

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
                          const Text(
                            'Arun 👋',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
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
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.secondary.withValues(
                        alpha: 0.15,
                      ),
                      child: const Text(
                        'A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search barbers, services...',
                      hintStyle: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppTheme.textGrey,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),

            // ── Filters ──
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  itemCount: _filters.length,
                  itemBuilder: (_, i) {
                    final active = _filter == _filters[i];
                    return GestureDetector(
                      onTap: () => setState(() => _filter = _filters[i]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: active ? AppTheme.secondary : AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active
                                ? AppTheme.secondary
                                : AppTheme.border,
                          ),
                        ),
                        child: Text(
                          _filters[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: active ? Colors.white : AppTheme.textGrey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Promo banner ──
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'First booking free!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Use code FIRST50 at checkout',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code FIRST50 copied! 🎉'),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Claim',
                          style: TextStyle(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Section heading ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _query.isNotEmpty
                          ? 'Results for "$_query"'
                          : _filter == 'All'
                          ? 'Barbers near you'
                          : _filter,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${_filtered.length} found',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Barber list ──
            _filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppTheme.textGrey.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No barbers found',
                              style: TextStyle(color: AppTheme.textGrey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((_, i) {
                      final b = _filtered[i];
                      final isFav = favouriteBarberIds.contains(b.id);
                      return _BarberCard(
                        barber: b,
                        isFav: isFav,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BarberProfileScreen(barber: b),
                          ),
                        ),
                        onFavToggle: () => _toggleFav(b.id),
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

class _BarberCard extends StatelessWidget {
  final BarberModel barber;
  final bool isFav;
  final VoidCallback onTap, onFavToggle;
  const _BarberCard({
    required this.barber,
    required this.isFav,
    required this.onTap,
    required this.onFavToggle,
  });

  @override
  Widget build(BuildContext context) {
    final minPrice = barber.services.isNotEmpty
        ? barber.services.map((s) => s.price).reduce((a, b) => a < b ? a : b)
        : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.secondary.withValues(alpha: 0.12),
                  child: Text(
                    barber.initial,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: barber.isOpen
                          ? const Color(0xFF1D9E75)
                          : AppTheme.textGrey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          barber.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onFavToggle,
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFav
                              ? const Color(0xFFE24B4A)
                              : AppTheme.textGrey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    barber.shopName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFEF9F27),
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${barber.rating}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        ' (${barber.reviewCount})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppTheme.textGrey,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          barber.location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'From ₹$minPrice',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: barber.isOpen
                              ? const Color(0xFF1D9E75).withValues(alpha: 0.1)
                              : AppTheme.textGrey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          barber.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: barber.isOpen
                                ? const Color(0xFF1D9E75)
                                : AppTheme.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
