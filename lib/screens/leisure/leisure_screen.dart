// lib/screens/leisure/leisure_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

class LeisureScreen extends StatefulWidget {
  final int initialTab;
  const LeisureScreen({super.key, this.initialTab = 0});

  @override
  State<LeisureScreen> createState() => _LeisureScreenState();
}

class _LeisureScreenState extends State<LeisureScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _activeTab = 0;

  final _tabs = const [
    {'icon': '🧖', 'label': 'Spa & Salon'},
    {'icon': '🎤', 'label': 'Events'},
    {'icon': '🎡', 'label': 'Parks'},
    {'icon': '🧗', 'label': 'Adventure'},
  ];

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab.clamp(0, _tabs.length - 1);
    _tabCtrl = TabController(
        length: _tabs.length, vsync: this, initialIndex: _activeTab);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _activeTab = _tabCtrl.index);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: AppColors.catLeisure,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.catLeisure,
                child: Stack(children: [
                  Positioned(
                    top: -20, right: -20,
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        const Text('🎭', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 6),
                        const Text(
                          'Leisure',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Relax, unwind & experience more',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const _StatItem(value: '200+', label: 'Experiences'),
                              Container(width: 1, height: 32, color: Colors.white30),
                              const _StatItem(value: '50+', label: 'Spas & Salons'),
                              Container(width: 1, height: 32, color: Colors.white30),
                              const _StatItemWithStar(value: '4.9', label: 'Rating'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: AppColors.catLeisure,
                child: TabBar(
                  controller: _tabCtrl,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  tabs: _tabs.map((t) => Tab(text: '${t['icon']}  ${t['label']}')).toList(),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: const [
            _SpaTab(),
            _EventsTab(),
            _ParksTab(),
            _AdventureTab(),
          ],
        ),
      ),
    );
  }
}

// ─── STAT WIDGETS ─────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(fontSize: 11, color: Colors.white70)),
    ]);
  }
}

class _StatItemWithStar extends StatelessWidget {
  final String value;
  final String label;
  const _StatItemWithStar({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(width: 3),
        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
      ]),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(fontSize: 11, color: Colors.white70)),
    ]);
  }
}

// ─── DATA ─────────────────────────────────────────────────────────────────────

const _spas = [
  {'name': 'Serene Spa & Wellness',  'location': 'Bandra West, Mumbai', 'rating': '4.8', 'reviews': '1.2k', 'price': 999,  'originalPrice': 1499, 'tag': 'Best Seller', 'tagColor': 0xFF7C4DFF, 'services': 'Body Massage • Facial • Scrub',      'duration': '60 min',  'icon': '🧖‍♀️', 'filter': 'Spa'},
  {'name': 'Royal Touch Salon',      'location': 'Andheri, Mumbai',     'rating': '4.6', 'reviews': '890',  'price': 599,  'originalPrice': 799,  'tag': 'Popular',     'tagColor': 0xFFE91E63, 'services': 'Hair Cut • Colour • Styling',       'duration': '45 min',  'icon': '💇‍♀️', 'filter': 'Salon'},
  {'name': 'Zen Ayurveda Centre',    'location': 'Juhu, Mumbai',        'rating': '4.9', 'reviews': '2.1k', 'price': 1299, 'originalPrice': 1999, 'tag': 'Top Rated',   'tagColor': 0xFF00897B, 'services': 'Shirodhara • Abhyangam • Steam',    'duration': '90 min',  'icon': '🌿',   'filter': 'Ayurveda'},
  {'name': 'Glow Beauty Studio',     'location': 'Powai, Mumbai',       'rating': '4.5', 'reviews': '540',  'price': 449,  'originalPrice': 599,  'tag': 'New',         'tagColor': 0xFFFF6F00, 'services': 'Facial • Threading • Waxing',       'duration': '30 min',  'icon': '✨',   'filter': 'Nail Art'},
  {'name': 'The Nail Bar',           'location': 'Malad, Mumbai',       'rating': '4.4', 'reviews': '310',  'price': 349,  'originalPrice': 499,  'tag': 'Trending',    'tagColor': 0xFFE91E63, 'services': 'Gel Nails • Extensions • Art',      'duration': '45 min',  'icon': '💅',   'filter': 'Nail Art'},
  {'name': 'O2 Spa Lounge',          'location': 'Goregaon, Mumbai',    'rating': '4.7', 'reviews': '980',  'price': 799,  'originalPrice': 1199, 'tag': 'Popular',     'tagColor': 0xFF7C4DFF, 'services': 'Swedish Massage • Head Spa • Scrub','duration': '75 min',  'icon': '🧘',   'filter': 'Spa'},
];

const _events = [
  {'name': 'Armaan Malik Live Concert',  'venue': 'MMRDA Grounds, BKC',         'price': 799,  'category': 'Music',    'icon': '🎤', 'tag': 'Selling Fast', 'tagColor': 0xFFE91E63, 'seatsLeft': '42 seats left',  'filter': 'Music'},
  {'name': 'Mumbai Comedy Night',        'venue': 'Canvas Laugh Club, Andheri', 'price': 499,  'category': 'Comedy',   'icon': '🎭', 'tag': 'Hot',          'tagColor': 0xFFFF6F00, 'seatsLeft': '18 seats left',  'filter': 'Comedy'},
  {'name': 'Sunburn Arena ft. DJ Nucleya','venue': 'Dome, NSCI, Worli',         'price': 1299, 'category': 'Music',    'icon': '🎧', 'tag': 'Featured',     'tagColor': 0xFF7C4DFF, 'seatsLeft': '120 seats left', 'filter': 'Music'},
  {'name': 'Bollywood Dance Workshop',   'venue': 'Shiamak Studio, Lower Parel','price': 299,  'category': 'Workshop', 'icon': '💃', 'tag': 'New',          'tagColor': 0xFF00897B, 'seatsLeft': '30 seats left',  'filter': 'Workshop'},
  {'name': 'IPL Watch Party',            'venue': 'Hard Rock Cafe, Worli',      'price': 599,  'category': 'Sports',   'icon': '🏏', 'tag': 'Hot',          'tagColor': 0xFFFF9800, 'seatsLeft': '25 seats left',  'filter': 'Sports'},
  {'name': 'Open Mic Night',             'venue': 'The Habitat, Khar',          'price': 199,  'category': 'Comedy',   'icon': '🎙️', 'tag': 'Chill',        'tagColor': 0xFF00897B, 'seatsLeft': '50 seats left',  'filter': 'Comedy'},
];

const _parks = [
  {'name': 'Imagica Theme Park',  'location': 'Khopoli, 2hrs from Mumbai',     'rating': '4.7', 'reviews': '8.5k', 'price': 1299, 'originalPrice': 1799, 'tag': 'Family Favourite', 'tagColor': 0xFFFF9800, 'services': '40+ Rides • Water Park • Snow Park',          'duration': 'Open 10AM – 8PM', 'icon': '🎢', 'filter': 'Theme Park'},
  {'name': 'Essel World',         'location': 'Gorai, Mumbai',                  'rating': '4.4', 'reviews': '12k',  'price': 899,  'originalPrice': 1199, 'tag': 'Kids Fave',        'tagColor': 0xFF2196F3, 'services': '35+ Rides • Water Kingdom combo',              'duration': 'Open 10AM – 7PM', 'icon': '🎠', 'filter': 'Theme Park'},
  {'name': 'Wet N Joy, Lonavala', 'location': 'Lonavala, 1.5hrs from Mumbai',  'rating': '4.3', 'reviews': '5.2k', 'price': 749,  'originalPrice': 999,  'tag': 'Water Fun',        'tagColor': 0xFF00BCD4, 'services': '25+ Water Slides • Wave Pool • Lazy River',    'duration': 'Open 10AM – 6PM', 'icon': '🌊', 'filter': 'Water Park'},
  {'name': 'Sanjay Gandhi Park',  'location': 'Borivali, Mumbai',               'rating': '4.5', 'reviews': '14k',  'price': 80,   'originalPrice': 80,   'tag': 'Nature Escape',    'tagColor': 0xFF2E7D32, 'services': 'Trekking • Boating • Cave Exploration',        'duration': 'Open 7AM – 7PM',  'icon': '🌳', 'filter': 'Nature'},
  {'name': 'Byculla Zoo',         'location': 'Byculla, Mumbai',                'rating': '4.1', 'reviews': '6.8k', 'price': 50,   'originalPrice': 50,   'tag': 'Kids Love',        'tagColor': 0xFFE91E63, 'services': '300+ Animals • Nocturnal House • Aquarium',    'duration': 'Open 9AM – 6PM',  'icon': '🦁', 'filter': 'Zoo'},
];

const _activities = [
  {'name': 'Paragliding at Kamshet',  'location': 'Kamshet, Pune',         'rating': '4.9', 'reviews': '3.1k', 'price': 2499, 'originalPrice': 3200, 'tag': 'Thrill Seeker', 'tagColor': 0xFFE91E63, 'services': 'Tandem Flight • 20 min airtime',          'duration': 'Half Day', 'icon': '🪂', 'filter': 'Flying'},
  {'name': 'Scuba Diving, Alibaug',   'location': 'Alibaug, Maharashtra',  'rating': '4.7', 'reviews': '1.8k', 'price': 1999, 'originalPrice': 2500, 'tag': 'Popular',       'tagColor': 0xFF2196F3, 'services': 'Beginner dive • Equipment • Trainer',     'duration': '3 hours',  'icon': '🤿', 'filter': 'Water'},
  {'name': 'Trekking – Rajmachi Fort','location': 'Lonavala, Maharashtra', 'rating': '4.6', 'reviews': '4.5k', 'price': 799,  'originalPrice': 1100, 'tag': 'Group Fun',     'tagColor': 0xFF00897B, 'services': 'Guide • Breakfast • Safety gear',         'duration': 'Full Day', 'icon': '🧗', 'filter': 'Trekking'},
  {'name': 'River Rafting, Kolad',    'location': 'Kolad, Raigad',         'rating': '4.8', 'reviews': '6.2k', 'price': 1299, 'originalPrice': 1799, 'tag': 'Best Seller',   'tagColor': 0xFF7C4DFF, 'services': '14km stretch • Life jacket • Kayaking',  'duration': '4 hours',  'icon': '🚣', 'filter': 'Water'},
  {'name': 'Cycling – Aarey Colony',  'location': 'Goregaon, Mumbai',      'rating': '4.5', 'reviews': '2.3k', 'price': 599,  'originalPrice': 799,  'tag': 'Popular',       'tagColor': 0xFF8BC34A, 'services': 'Cycle rental • Guide • Breakfast',        'duration': '3 hours',  'icon': '🚴', 'filter': 'Cycling'},
  {'name': 'Hot Air Balloon, Pune',   'location': 'Pune, Maharashtra',     'rating': '4.8', 'reviews': '1.1k', 'price': 4999, 'originalPrice': 6500, 'tag': 'Luxury',        'tagColor': 0xFFFF6F00, 'services': '45 min flight • Champagne • Certificate', 'duration': '3 hours',  'icon': '🎈', 'filter': 'Flying'},
];

// ─── TABS ─────────────────────────────────────────────────────────────────────

class _SpaTab extends StatefulWidget {
  const _SpaTab();
  @override
  State<_SpaTab> createState() => _SpaTabState();
}
class _SpaTabState extends State<_SpaTab> {
  String _active = 'All';
  final _filters = ['All', 'Spa', 'Salon', 'Ayurveda', 'Nail Art'];

  List<Map<String, dynamic>> get _filtered => _active == 'All'
      ? List<Map<String, dynamic>>.from(_spas)
      : List<Map<String, dynamic>>.from(_spas.where((s) => s['filter'] == _active));

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _OfferBanner(icon: '💆', title: '30% OFF on First Spa', subtitle: 'Use code: RELAXFK', color: AppColors.catLeisure),
        const SizedBox(height: 16),
        _FilterRow(filters: _filters, active: _active, onSelect: (f) => setState(() => _active = f)),
        const SizedBox(height: 16),
        if (_filtered.isEmpty)
          _EmptyFilter(filter: _active)
        else
          ..._filtered.map((s) => _ServiceCard(data: s, type: 'spa')),
      ],
    );
  }
}

class _EventsTab extends StatefulWidget {
  const _EventsTab();
  @override
  State<_EventsTab> createState() => _EventsTabState();
}
class _EventsTabState extends State<_EventsTab> {
  String _active = 'All';
  final _filters = ['All', 'Music', 'Comedy', 'Workshop', 'Sports'];

  List<Map<String, dynamic>> get _filtered => _active == 'All'
      ? List<Map<String, dynamic>>.from(_events)
      : List<Map<String, dynamic>>.from(_events.where((e) => e['filter'] == _active));

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _OfferBanner(icon: '🎟️', title: 'Buy 2 Get 1 FREE on Events', subtitle: 'This weekend only!', color: Color(0xFFE91E63)),
        const SizedBox(height: 16),
        _FilterRow(filters: _filters, active: _active, onSelect: (f) => setState(() => _active = f)),
        const SizedBox(height: 16),
        if (_filtered.isEmpty)
          _EmptyFilter(filter: _active)
        else
          ..._filtered.map((e) => _EventCard(data: e)),
      ],
    );
  }
}

class _ParksTab extends StatefulWidget {
  const _ParksTab();
  @override
  State<_ParksTab> createState() => _ParksTabState();
}
class _ParksTabState extends State<_ParksTab> {
  String _active = 'All';
  final _filters = ['All', 'Theme Park', 'Water Park', 'Nature', 'Zoo'];

  List<Map<String, dynamic>> get _filtered => _active == 'All'
      ? List<Map<String, dynamic>>.from(_parks)
      : List<Map<String, dynamic>>.from(_parks.where((p) => p['filter'] == _active));

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _OfferBanner(icon: '🎡', title: 'Kids FREE on Weekends', subtitle: 'For children below 5 years', color: Color(0xFFFF9800)),
        const SizedBox(height: 16),
        _FilterRow(filters: _filters, active: _active, onSelect: (f) => setState(() => _active = f)),
        const SizedBox(height: 16),
        if (_filtered.isEmpty)
          _EmptyFilter(filter: _active)
        else
          ..._filtered.map((p) => _ServiceCard(data: p, type: 'park')),
      ],
    );
  }
}

class _AdventureTab extends StatefulWidget {
  const _AdventureTab();
  @override
  State<_AdventureTab> createState() => _AdventureTabState();
}
class _AdventureTabState extends State<_AdventureTab> {
  String _active = 'All';
  final _filters = ['All', 'Flying', 'Water', 'Trekking', 'Cycling'];

  List<Map<String, dynamic>> get _filtered => _active == 'All'
      ? List<Map<String, dynamic>>.from(_activities)
      : List<Map<String, dynamic>>.from(_activities.where((a) => a['filter'] == _active));

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _OfferBanner(icon: '🧗', title: 'Group Discount: 20% OFF', subtitle: 'Book for 4+ people', color: Color(0xFF7C4DFF)),
        const SizedBox(height: 16),
        _FilterRow(filters: _filters, active: _active, onSelect: (f) => setState(() => _active = f)),
        const SizedBox(height: 16),
        if (_filtered.isEmpty)
          _EmptyFilter(filter: _active)
        else
          ..._filtered.map((a) => _ServiceCard(data: a, type: 'adventure')),
      ],
    );
  }
}

// ─── EMPTY STATE ──────────────────────────────────────────────────────────────

class _EmptyFilter extends StatelessWidget {
  final String filter;
  const _EmptyFilter({required this.filter});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        const Text('🔍', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text('No "$filter" listings right now',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Try a different filter',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    );
  }
}

// ─── FILTER ROW ───────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final String active;
  final ValueChanged<String> onSelect;
  const _FilterRow({required this.filters, required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isActive = filters[i] == active;
          return GestureDetector(
            onTap: () => onSelect(filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.catLeisure : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? AppColors.catLeisure : AppColors.border),
                boxShadow: isActive
                    ? [BoxShadow(color: AppColors.catLeisure.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Text(filters[i],
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : AppColors.textSecondary)),
            ),
          );
        },
      ),
    );
  }
}

// ─── OFFER BANNER ─────────────────────────────────────────────────────────────

class _OfferBanner extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  const _OfferBanner({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.75)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 36)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Text('Grab', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}

// ─── SERVICE CARD (Spa / Park / Adventure) ────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String type;
  const _ServiceCard({required this.data, required this.type});

  @override
  Widget build(BuildContext context) {
    final tagColor = Color(data['tagColor'] as int);
    final price = data['price'] as int;
    final originalPrice = data['originalPrice'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            color: tagColor.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Text(data['icon'] as String, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(data['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(data['location'] as String,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(8)),
                child: Text(data['tag'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                Text(' ${data['rating']}  (${data['reviews']})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ]),
            ]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(type == 'park' ? Icons.local_activity_rounded : Icons.spa_rounded, size: 13, color: tagColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text((data['services']) as String,
                    style: TextStyle(fontSize: 11, color: tagColor, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ]),
            if (data.containsKey('duration')) ...[
              const SizedBox(height: 4),
              Row(children: [
                Icon(type == 'park' ? Icons.access_time_rounded : Icons.timer_rounded,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Text(data['duration'] as String,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ]),
            ],
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('₹$price',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: tagColor)),
                  const SizedBox(width: 6),
                  if (originalPrice > price)
                    Text('₹$originalPrice',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough)),
                ]),
                const Text('per person', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ]),
              GestureDetector(
                onTap: () => _showBookingSheet(context, data, tagColor, price),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [tagColor, tagColor.withValues(alpha: 0.8)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: tagColor.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Text('Book Now', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  void _showBookingSheet(BuildContext context, Map<String, dynamic> data, Color color, int pricePerPerson) {
    // ── CHANGE 1: guests starts at 0 ──
    int guests = 0;
    int selectedDateIdx = 0;
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Row(children: [
              Text(data['icon'] as String, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(data['name'] as String,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(data['location'] as String,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
              ),
            ]),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Select Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final day = now.add(Duration(days: i));
                  final isSelected = i == selectedDateIdx;
                  return GestureDetector(
                    onTap: () => setS(() => selectedDateIdx = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 52,
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? color : AppColors.border),
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
                            : [],
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(dayNames[day.weekday - 1],
                            style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        Text('${day.day}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : AppColors.textPrimary)),
                        Text(_monthShort(day.month),
                            style: TextStyle(fontSize: 9, color: isSelected ? Colors.white60 : AppColors.textSecondary)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Number of Guests', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Row(children: [
                GestureDetector(
                  // ── CHANGE 1: min guests is 0 ──
                  onTap: () { if (guests > 0) setS(() => guests--); },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.remove, size: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('$guests', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                GestureDetector(
                  onTap: () => setS(() => guests++),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ]),
            ]),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text('₹${pricePerPerson * guests}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                // ── CHANGE 2: "Confirm Booking" opens user details form ──
                onPressed: guests == 0
                    ? null
                    : () {
                        final selectedDay = now.add(Duration(days: selectedDateIdx));
                        Navigator.pop(context);
                        _showUserDetailsForm(
                          context: context,
                          data: data,
                          color: color,
                          guests: guests,
                          selectedDay: selectedDay,
                          pricePerPerson: pricePerPerson,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  disabledBackgroundColor: color.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Confirm Booking', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── CHANGE 2: User details form ──────────────────────────────────────────────
  void _showUserDetailsForm({
    required BuildContext context,
    required Map<String, dynamic> data,
    required Color color,
    required int guests,
    required DateTime selectedDay,
    required int pricePerPerson,
  }) {
    final nameCtrl  = TextEditingController();
    final roomCtrl  = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey   = GlobalKey<FormState>();
    final dateStr   = '${selectedDay.day} ${_monthShort(selectedDay.month)}';
    final total     = pricePerPerson * guests;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Your Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${data['name']}  •  $guests guest${guests == 1 ? '' : 's'}  •  $dateStr  •  ₹$total',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDeco('Full Name', Icons.person_outline, color),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 14),

                // Room
                TextFormField(
                  controller: roomCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco('Room Number', Icons.door_front_door_outlined, color),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter room number' : null,
                ),
                const SizedBox(height: 14),

                // Phone
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDeco('Phone Number', Icons.phone_outlined, color),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter phone number';
                    if (v.trim().length < 10) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✅  ${data['name']} booked for $guests guest${guests > 1 ? 's' : ''} on $dateStr!\n'
                              'Name: ${nameCtrl.text.trim()}, Room: ${roomCtrl.text.trim()}',
                            ),
                            backgroundColor: color,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Confirm Booking',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon, Color color) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: color),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 2),
    ),
  );

  String _monthShort(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}

// ─── EVENT CARD ───────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _EventCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final tagColor = Color(data['tagColor'] as int);
    final price = data['price'] as int;
    final now = DateTime.now();

    final eventDate = now.add(Duration(days: (price % 6) + 1));
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${dayNames[eventDate.weekday - 1]}, ${eventDate.day} ${months[eventDate.month - 1]} ${eventDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text(data['icon'] as String, style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(6)),
                  child: Text(data['tag'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 6),
                Text(data['category'] as String,
                    style: TextStyle(fontSize: 10, color: tagColor, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 5),
              Text(data['name'] as String,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_rounded, size: 11, color: AppColors.textSecondary),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(data['venue'] as String,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ]),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textSecondary),
                const SizedBox(width: 3),
                Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('₹$price',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: tagColor)),
                  Text(data['seatsLeft'] as String,
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ]),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎟️  Booked: ${data['name']} on $dateStr'),
                      backgroundColor: tagColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [tagColor, tagColor.withValues(alpha: 0.8)]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: tagColor.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: const Text('Get Tickets', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}