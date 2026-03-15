import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';
import 'barber_profile_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<BarberModel> get _favBarbers =>
      allBarbers.where((b) => favouriteBarberIds.contains(b.id)).toList();

  void _remove(String id) {
    setState(() => favouriteBarberIds.remove(id));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Removed from favourites')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Favourites',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  Text(
                    '${_favBarbers.length} saved',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),

            _favBarbers.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 56,
                            color: AppTheme.textGrey.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No favourites yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap ♡ on any barber to save them',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _favBarbers.length,
                      itemBuilder: (_, i) {
                        final b = _favBarbers[i];
                        final minPrice = b.services.isNotEmpty
                            ? b.services
                                  .map((s) => s.price)
                                  .reduce((a, b) => a < b ? a : b)
                            : 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
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
                                    radius: 28,
                                    backgroundColor: AppTheme.secondary
                                        .withValues(alpha: 0.12),
                                    child: Text(
                                      b.initial,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.secondary,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 13,
                                      height: 13,
                                      decoration: BoxDecoration(
                                        color: b.isOpen
                                            ? const Color(0xFF1D9E75)
                                            : AppTheme.textGrey,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
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
                                    Text(
                                      b.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      b.specialty,
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
                                          size: 12,
                                          color: Color(0xFFEF9F27),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${b.rating}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textGrey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'From ₹$minPrice',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.secondary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          b.isOpen ? '● Open' : '● Closed',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: b.isOpen
                                                ? const Color(0xFF1D9E75)
                                                : AppTheme.textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.favorite_rounded,
                                      color: Color(0xFFE24B4A),
                                      size: 22,
                                    ),
                                    onPressed: () => _remove(b.id),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            BarberProfileScreen(barber: b),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Book',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
