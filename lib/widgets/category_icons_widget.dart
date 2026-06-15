// lib/widgets/category_icons_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _Category {
  final IconData icon;
  final String label;
  final Color bgColor;
  final String route;
  final String? badge;

  const _Category({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.route,
    this.badge,
  });
}

const List<_Category> _primaryCategories = [
  _Category(
    icon: Icons.restaurant_rounded,
    label: 'Food',
    bgColor: Color(0xFFFF6B35),
    route: '/category/food',
  ),
  _Category(
    icon: Icons.movie_rounded,
    label: 'Movies',
    bgColor: Color(0xFFE91E63),
    route: '/category/movies',
  ),
  _Category(
    icon: Icons.hotel_rounded,
    label: 'Hotels',
    bgColor: Color(0xFF6D4C41),
    route: '/category/hotels',
    badge: '₹88 off',
  ),
  _Category(
    icon: Icons.theater_comedy_rounded,
    label: 'Leisure',
    bgColor: Color(0xFF00897B),
    route: '/category/leisure',
  ),
  _Category(
    icon: Icons.delivery_dining_rounded,
    label: 'Delivery',
    bgColor: Color(0xFFF5A800),
    route: '/category/delivery',
  ),
];

const List<_Category> _secondaryCategories = [
  _Category(
    icon: Icons.local_taxi_rounded,
    label: 'Ride',
    bgColor: Color(0xFF1976D2),
    route: '/category/ride',
    badge: 'New',
  ),
  _Category(
    icon: Icons.pedal_bike_rounded,
    label: 'Bike',
    bgColor: Color(0xFF388E3C),
    route: '/category/bike',
  ),
  _Category(
    icon: Icons.flight_rounded,
    label: 'Travel',
    bgColor: Color(0xFFFF9800),
    route: '/category/travel',
  ),
  _Category(
    icon: Icons.shopping_cart_rounded,
    label: 'Grocery',
    bgColor: Color(0xFF26A69A),
    route: '/category/grocery',
  ),
  _Category(
    icon: Icons.more_horiz_rounded,
    label: 'More',
    bgColor: Color(0xFF757575),
    route: '/category/more',
  ),
];

class CategoryIconsWidget extends StatelessWidget {
  const CategoryIconsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const _CategoryRow(categories: _primaryCategories, iconSize: 52),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 16),
          const _CategoryRow(categories: _secondaryCategories, iconSize: 44),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final List<_Category> categories;
  final double iconSize;

  const _CategoryRow({required this.categories, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: categories
          .map((cat) => _CategoryItem(category: cat, iconSize: iconSize))
          .toList(),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final _Category category;
  final double iconSize;

  const _CategoryItem({required this.category, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    final isLarge = iconSize >= 52;

    return GestureDetector(
      onTap: () => context.push(category.route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: category.bgColor,
                  borderRadius: BorderRadius.circular(isLarge ? 14 : 12),
                  boxShadow: [
                    BoxShadow(
                      color: category.bgColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  category.icon,
                  color: Colors.white,
                  size: isLarge ? 26 : 22,
                ),
              ),
              if (category.badge != null)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: category.badge == 'New'
                          ? const Color(0xFF34C759)
                          : const Color(0xFFFF3B30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: iconSize + 8,
            child: Text(
              category.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}