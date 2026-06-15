// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../services/mock_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  final List<String> _recent = ['Butter Chicken', 'Masala Dosa', 'Pizza', 'Biryani', 'Burger'];
  final List<Map<String, String>> _trending = [
    {'name': 'Punjabi Tadka', 'tag': 'Restaurant', 'icon': '🍛'},
    {'name': 'Pushpa 2', 'tag': 'Movies', 'icon': '🎬'},
    {'name': 'Mangoes', 'tag': 'Grocery', 'icon': '🥭'},
    {'name': 'Cab to Airport', 'tag': 'Rides', 'icon': '🚕'},
    {'name': 'Taj Hotel', 'tag': 'Hotels', 'icon': '🏨'},
    {'name': 'Masala Dosa', 'tag': 'Food', 'icon': '🥞'},
  ];

  List<_SearchResult> get _results {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    final results = <_SearchResult>[];

    // Restaurants
    for (final r in MockData.restaurants()) {
      if (r.name.toLowerCase().contains(q) ||
          r.categories.any((c) => c.toLowerCase().contains(q))) {
        results.add(_SearchResult(
          id: r.id, title: r.name,
          subtitle: r.categories.join(' · '),
          meta: '${r.rating}⭐  ${r.deliveryTime}',
          type: 'restaurant', imageUrl: r.imageUrl, route: '/restaurant/${r.id}',
        ));
      }
      // Menu items
      for (final item in r.menu) {
        if (item.name.toLowerCase().contains(q)) {
          results.add(_SearchResult(
            id: item.id, title: item.name,
            subtitle: r.name,
            meta: '₹${item.price.toInt()}',
            type: 'food', imageUrl: item.imageUrl, route: '/restaurant/${r.id}',
          ));
        }
      }
    }

    // Categories
    for (final cat in MockData.categories()) {
      if (cat.name.toLowerCase().contains(q)) {
        results.add(_SearchResult(
          id: cat.id, title: cat.name,
          subtitle: 'Category',
          meta: '', type: 'category',
          imageUrl: '', route: cat.route, emoji: cat.icon,
        ));
      }
    }

    return results;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      // bg handled by theme
      appBar: AppBar(
        // bg handled by theme
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Search food, movies, hotels...',
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () { _ctrl.clear(); setState(() => _query = ''); })
                : null,
          ),
        ),
      ),
      body: _query.isEmpty ? _homeState() : _resultsState(results),
    );
  }

  Widget _homeState() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Recent
      if (_recent.isNotEmpty) ...[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Recent Searches', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          TextButton(onPressed: () => setState(() => _recent.clear()),
              child: const Text('Clear', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _recent.map((r) => GestureDetector(
          onTap: () { _ctrl.text = r; setState(() => _query = r); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.history_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(r, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
        )).toList()),
        const SizedBox(height: 24),
      ],

      // Trending
      const Text('Trending Now 🔥', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      ...List.generate(_trending.length, (i) {
        final t = _trending[i];
        return GestureDetector(
          onTap: () { _ctrl.text = t['name']!; setState(() => _query = t['name']!); },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
            child: Row(children: [
              Text(t['icon']!, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Text(t['tag']!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 18),
            ]),
          ),
        );
      }),

      const SizedBox(height: 24),
      const Text('Browse Categories', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4, childAspectRatio: 1.1,
        crossAxisSpacing: 8, mainAxisSpacing: 8,
        children: MockData.categories().map((cat) => GestureDetector(
          onTap: () => context.push(cat.route),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(cat.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(cat.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        )).toList(),
      ),
    ]);
  }

  Widget _resultsState(List<_SearchResult> results) {
    if (results.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🔍', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text('No results for "$_query"', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Try different keywords', style: TextStyle(color: AppColors.textSecondary)),
      ]));
    }

    // Group by type
    final restaurants = results.where((r) => r.type == 'restaurant').toList();
    final foods = results.where((r) => r.type == 'food').toList();
    final cats = results.where((r) => r.type == 'category').toList();

    return ListView(padding: const EdgeInsets.all(12), children: [
      Text('${results.length} results for "$_query"',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 12),
      if (cats.isNotEmpty) ...[
        _sectionHeader('Categories'),
        ...cats.map((r) => _ResultTile(result: r)),
        const SizedBox(height: 8),
      ],
      if (restaurants.isNotEmpty) ...[
        _sectionHeader('Restaurants'),
        ...restaurants.map((r) => _ResultTile(result: r)),
        const SizedBox(height: 8),
      ],
      if (foods.isNotEmpty) ...[
        _sectionHeader('Dishes'),
        ...foods.map((r) => _ResultTile(result: r)),
      ],
    ]);
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
  );
}

class _SearchResult {
  final String id, title, subtitle, meta, type, imageUrl, route;
  final String emoji;
  _SearchResult({required this.id, required this.title, required this.subtitle,
      required this.meta, required this.type, required this.imageUrl,
      required this.route, this.emoji = ''});
}

class _ResultTile extends StatelessWidget {
  final _SearchResult result;
  const _ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(result.route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
        child: Row(children: [
          result.type == 'category'
              ? Container(width: 48, height: 48,
                  decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(result.emoji, style: const TextStyle(fontSize: 24))))
              : ClipRRect(borderRadius: BorderRadius.circular(10),
                  child: Image.network(result.imageUrl, width: 48, height: 48, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 48, height: 48,
                          color: AppColors.divider, child: const Icon(Icons.image_rounded, color: AppColors.textHint)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(result.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            Text(result.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          if (result.meta.isNotEmpty)
            Text(result.meta, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textHint),
        ]),
      ),
    );
  }
}