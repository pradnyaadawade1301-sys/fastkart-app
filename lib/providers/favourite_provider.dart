// lib/screens/favourite/favourite_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/app_models.dart';
import '../../providers/favourites_provider.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        automaticallyImplyLeading: false,
        title: const Text('Favourites ❤️',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: Consumer<FavouritesProvider>(
        builder: (_, fav, __) {
          if (fav.favourites.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('💔', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text('No favourites yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('Save restaurants you love\nand find them here!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Explore Restaurants',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ]),
            );
          }

          return Column(children: [
            // Header count
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                Text('${fav.count} saved restaurant${fav.count == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: fav.favourites.length,
                itemBuilder: (_, i) => _FavCard(
                  restaurant: fav.favourites[i],
                  onRemove: () => fav.removeFavourite(fav.favourites[i].id),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onRemove;
  const _FavCard({required this.restaurant, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return Dismissible(
      key: Key(r.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(20)),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.favorite_border_rounded, color: Colors.white, size: 26),
          SizedBox(height: 4),
          Text('Remove', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      ),
      child: GestureDetector(
        onTap: () => context.push('/restaurant/${r.id}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              child: Image.network(r.imageUrl, width: 100, height: 100, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 100, height: 100,
                      color: AppColors.divider,
                      child: const Icon(Icons.restaurant, size: 36, color: AppColors.textHint))),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(r.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: r.isOpen ? AppColors.success.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(r.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              color: r.isOpen ? AppColors.success : Colors.red)),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text(r.categories.join(' · '),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
                    Text(' ${r.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary),
                    Text(' ${r.deliveryTime}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(width: 10),
                    Text(r.deliveryFee == 0 ? 'FREE delivery' : '₹${r.deliveryFee.toInt()} delivery',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: r.deliveryFee == 0 ? AppColors.success : AppColors.textSecondary)),
                  ]),
                ]),
              ),
            ),
            // Remove button
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded, size: 18, color: Colors.red),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}