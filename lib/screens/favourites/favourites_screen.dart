// lib/screens/favourites/favourites_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/favourites_provider.dart';
import '../../models/app_models.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bg handled by theme
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        title: const Text('Saved', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: Consumer<FavouritesProvider>(
        builder: (_, prov, __) {
          final favs = prov.favourites;
          if (favs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text('No Saved Items Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Tap the ♡ on any restaurant\nto save it here',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => context.go('/home'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFB300)]),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text('Explore Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ]),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header count
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('${favs.length} Saved ${favs.length == 1 ? 'Place' : 'Places'}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              ...favs.map((r) => _FavCard(restaurant: r)),
            ],
          );
        },
      ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final Restaurant restaurant;
  const _FavCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return GestureDetector(
      onTap: () => context.push('/restaurant/${r.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            child: Image.network(
              r.imageUrl,
              width: 100, height: 100, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100, height: 100,
                color: AppColors.divider,
                child: const Icon(Icons.restaurant, color: AppColors.textHint, size: 32),
              ),
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(r.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  GestureDetector(
                    onTap: () => context.read<FavouritesProvider>().removeFavourite(r.id),
                    child: const Icon(Icons.favorite_rounded, color: Colors.red, size: 20),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(r.categories.join(' · '),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(6)),
                    child: Row(children: [
                      const Icon(Icons.star_rounded, size: 11, color: Colors.white),
                      Text(' ${r.rating.toStringAsFixed(1)}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                  Text(' ${r.deliveryTime}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Text(r.deliveryFee == 0 ? '🆓 Free' : '₹${r.deliveryFee.toInt()} delivery',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: r.deliveryFee == 0 ? AppColors.success : AppColors.textSecondary)),
                ]),
                if (!r.isOpen)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Text('Currently Closed', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w700)),
                  ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}