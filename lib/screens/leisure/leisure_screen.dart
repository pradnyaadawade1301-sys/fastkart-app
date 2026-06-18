// lib/screens/leisure/leisure_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../services/history_service.dart';

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
      if (!_tabCtrl.indexIsChanging) setState(() => _activeTab = _tabCtrl.index);
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
                        const Text('Leisure',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 4),
                        const Text('Relax, unwind & experience more',
                            style: TextStyle(fontSize: 13, color: Colors.white70)),
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

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
  ]);
}

class _StatItemWithStar extends StatelessWidget {
  final String value, label;
  const _StatItemWithStar({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Row(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(width: 3),
      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
    ]),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
  ]);
}

const _spas = [
  {'name': 'Serene Spa & Wellness',  'location': 'Bandra West, Mumbai', 'rating': '4.8', 'reviews': '1.2k', 'price': 999,  'originalPrice': 1499, 'tag': 'Best Seller', 'tagColor': 0xFF7C4DFF, 'services': 'Body Massage • Facial • Scrub',      'duration': '60 min',  'icon': '🧖‍♀️', 'filter': 'Spa'},
  {'name': 'Royal Touch Salon',      'location': 'Andheri, Mumbai',     'rating': '4.6', 'reviews': '890',  'price': 599,  'originalPrice': 799,  'tag': 'Popular',     'tagColor': 0xFFE91E63, 'services': 'Hair Cut • Colour • Styling',       'duration': '45 min',  'icon': '💇‍♀️', 'filter': 'Salon'},
  {'name': 'Zen Ayurveda Centre',    'location': 'Juhu, Mumbai',        'rating': '4.9', 'reviews': '2.1k', 'price': 1299, 'originalPrice': 1999, 'tag': 'Top Rated',   'tagColor': 0xFF00897B, 'services': 'Shirodhara • Abhyangam • Steam',    'duration': '90 min',  'icon': '🌿',   'filter': 'Ayurveda'},
  {'name': 'Glow Beauty Studio',     'location': 'Powai, Mumbai',       'rating': '4.5', 'reviews': '540',  'price': 449,  'originalPrice': 599,  'tag': 'New',         'tagColor': 0xFFFF6F00, 'services': 'Facial • Threading • Waxing',       'duration': '30 min',  'icon': '✨',   'filter': 'Nail Art'},
  {'name': 'The Nail Bar',           'location': 'Malad, Mumbai',       'rating': '4.4', 'reviews': '310',  'price': 349,  'originalPrice': 499,  'tag': 'Trending',    'tagColor': 0xFFE91E63, 'services': 'Gel Nails • Extensions • Art',      'duration': '45 min',  'icon': '💅',   'filter': 'Nail Art'},
  {'name': 'O2 Spa Lounge',          'location': 'Goregaon, Mumbai',    'rating': '4.7', 'reviews': '980',  'price': 799,  'originalPrice': 1199, 'tag': 'Popular',     'tagColor': 0xFF7C4DFF, 'services': 'Swedish Massage • Head Spa • Scrub','duration': '75 min',  'icon': '🧘',   'filter': 'Spa'},
];

const _events = [
  {'name': 'Armaan Malik Live Concert',   'venue': 'MMRDA Grounds, BKC',          'price': 799,  'category': 'Music',    'icon': '🎤', 'tag': 'Selling Fast', 'tagColor': 0xFFE91E63, 'seatsLeft': '42 seats left',  'filter': 'Music'},
  {'name': 'Mumbai Comedy Night',         'venue': 'Canvas Laugh Club, Andheri',  'price': 499,  'category': 'Comedy',   'icon': '🎭', 'tag': 'Hot',          'tagColor': 0xFFFF6F00, 'seatsLeft': '18 seats left',  'filter': 'Comedy'},
  {'name': 'Sunburn Arena ft. DJ Nucleya','venue': 'Dome, NSCI, Worli',           'price': 1299, 'category': 'Music',    'icon': '🎧', 'tag': 'Featured',     'tagColor': 0xFF7C4DFF, 'seatsLeft': '120 seats left', 'filter': 'Music'},
  {'name': 'Bollywood Dance Workshop',    'venue': 'Shiamak Studio, Lower Parel', 'price': 299,  'category': 'Workshop', 'icon': '💃', 'tag': 'New',          'tagColor': 0xFF00897B, 'seatsLeft': '30 seats left',  'filter': 'Workshop'},
  {'name': 'IPL Watch Party',             'venue': 'Hard Rock Cafe, Worli',       'price': 599,  'category': 'Sports',   'icon': '🏏', 'tag': 'Hot',          'tagColor': 0xFFFF9800, 'seatsLeft': '25 seats left',  'filter': 'Sports'},
  {'name': 'Open Mic Night',              'venue': 'The Habitat, Khar',           'price': 199,  'category': 'Comedy',   'icon': '🎙️', 'tag': 'Chill',        'tagColor': 0xFF00897B, 'seatsLeft': '50 seats left',  'filter': 'Comedy'},
];

const _parks = [
  {'name': 'Imagica Theme Park',  'location': 'Khopoli, 2hrs from Mumbai',    'rating': '4.7', 'reviews': '8.5k', 'price': 1299, 'originalPrice': 1799, 'tag': 'Family Favourite', 'tagColor': 0xFFFF9800, 'services': '40+ Rides • Water Park • Snow Park',       'duration': 'Open 10AM – 8PM', 'icon': '🎢', 'filter': 'Theme Park'},
  {'name': 'Essel World',         'location': 'Gorai, Mumbai',                 'rating': '4.4', 'reviews': '12k',  'price': 899,  'originalPrice': 1199, 'tag': 'Kids Fave',        'tagColor': 0xFF2196F3, 'services': '35+ Rides • Water Kingdom combo',          'duration': 'Open 10AM – 7PM', 'icon': '🎠', 'filter': 'Theme Park'},
  {'name': 'Wet N Joy, Lonavala', 'location': 'Lonavala, 1.5hrs from Mumbai', 'rating': '4.3', 'reviews': '5.2k', 'price': 749,  'originalPrice': 999,  'tag': 'Water Fun',        'tagColor': 0xFF00BCD4, 'services': '25+ Water Slides • Wave Pool • Lazy River', 'duration': 'Open 10AM – 6PM', 'icon': '🌊', 'filter': 'Water Park'},
  {'name': 'Sanjay Gandhi Park',  'location': 'Borivali, Mumbai',              'rating': '4.5', 'reviews': '14k',  'price': 80,   'originalPrice': 80,   'tag': 'Nature Escape',    'tagColor': 0xFF2E7D32, 'services': 'Trekking • Boating • Cave Exploration',    'duration': 'Open 7AM – 7PM',  'icon': '🌳', 'filter': 'Nature'},
  {'name': 'Byculla Zoo',         'location': 'Byculla, Mumbai',               'rating': '4.1', 'reviews': '6.8k', 'price': 50,   'originalPrice': 50,   'tag': 'Kids Love',        'tagColor': 0xFFE91E63, 'services': '300+ Animals • Nocturnal House • Aquarium','duration': 'Open 9AM – 6PM',  'icon': '🦁', 'filter': 'Zoo'},
];

const _activities = [
  {'name': 'Paragliding at Kamshet',  'location': 'Kamshet, Pune',        'rating': '4.9', 'reviews': '3.1k', 'price': 2499, 'originalPrice': 3200, 'tag': 'Thrill Seeker', 'tagColor': 0xFFE91E63, 'services': 'Tandem Flight • 20 min airtime',         'duration': 'Half Day', 'icon': '🪂', 'filter': 'Flying'},
  {'name': 'Scuba Diving, Alibaug',   'location': 'Alibaug, Maharashtra', 'rating': '4.7', 'reviews': '1.8k', 'price': 1999, 'originalPrice': 2500, 'tag': 'Popular',       'tagColor': 0xFF2196F3, 'services': 'Beginner dive • Equipment • Trainer',    'duration': '3 hours',  'icon': '🤿', 'filter': 'Water'},
  {'name': 'Trekking – Rajmachi Fort','location': 'Lonavala, Maharashtra','rating': '4.6', 'reviews': '4.5k', 'price': 799,  'originalPrice': 1100, 'tag': 'Group Fun',     'tagColor': 0xFF00897B, 'services': 'Guide • Breakfast • Safety gear',        'duration': 'Full Day', 'icon': '🧗', 'filter': 'Trekking'},
  {'name': 'River Rafting, Kolad',    'location': 'Kolad, Raigad',        'rating': '4.8', 'reviews': '6.2k', 'price': 1299, 'originalPrice': 1799, 'tag': 'Best Seller',   'tagColor': 0xFF7C4DFF, 'services': '14km stretch • Life jacket • Kayaking', 'duration': '4 hours',  'icon': '🚣', 'filter': 'Water'},
  {'name': 'Cycling – Aarey Colony',  'location': 'Goregaon, Mumbai',     'rating': '4.5', 'reviews': '2.3k', 'price': 599,  'originalPrice': 799,  'tag': 'Popular',       'tagColor': 0xFF8BC34A, 'services': 'Cycle rental • Guide • Breakfast',       'duration': '3 hours',  'icon': '🚴', 'filter': 'Cycling'},
  {'name': 'Hot Air Balloon, Pune',   'location': 'Pune, Maharashtra',    'rating': '4.8', 'reviews': '1.1k', 'price': 4999, 'originalPrice': 6500, 'tag': 'Luxury',        'tagColor': 0xFFFF6F00, 'services': '45 min flight • Champagne • Certificate','duration': '3 hours',  'icon': '🎈', 'filter': 'Flying'},
];

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
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const _OfferBanner(icon: '💆', title: '30% OFF on First Spa', subtitle: 'Use code: RELAXFK', color: AppColors.catLeisure),
      const SizedBox(height: 16),
      _FilterRow(filters: _filters, active: _active, onSelect: (f) => setState(() => _active = f)),
      const SizedBox(height: 16),
      if (_filtered.isEmpty) _EmptyFilter(filter: _active)
      else ..._filtered.map((s) => _ServiceCard(data: s, type: 'spa')),
    ],
  );
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
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const _OfferBanner(icon: '🎟️', title: 'Buy 2 Get 1 FREE on Events', subtitle: 'This weekend only!', color: Color(0xFFE91E63)),
      const SizedBox(height: 16),
      _FilterRow(filters: _filters, active: _active, onSelect: (f) => setState(() => _active = f)),
      const SizedBox(height: 16),
      if (_filtered.isEmpty) _EmptyFilter(filter: _active)
      else ..._filtered.map((e) => _EventCard(data: e)),
    ],
  );
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
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const _OfferBanner(icon: '🎡', title: 'Kids FREE on Weekends', subtitle: 'For children below 5 years', color: Color(0xFFFF9800)),
      const SizedBox(height: 16),
      _FilterRow(filters: _filters, active: _active, onSelect: (f) => setState(() => _active = f)),
      const SizedBox(height: 16),
      if (_filtered.isEmpty) _EmptyFilter(filter: _active)
      else ..._filtered.map((p) => _ServiceCard(data: p, type: 'park')),
    ],
  );
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
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const _OfferBanner(icon: '🧗', title: 'Group Discount: 20% OFF', subtitle: 'Book for 4+ people', color: Color(0xFF7C4DFF)),
      const SizedBox(height: 16),
      _FilterRow(filters: _filters, active: _active, onSelect: (f) => setState(() => _active = f)),
      const SizedBox(height: 16),
      if (_filtered.isEmpty) _EmptyFilter(filter: _active)
      else ..._filtered.map((a) => _ServiceCard(data: a, type: 'adventure')),
    ],
  );
}

String _monthShort(int m) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return months[m - 1];
}

void showUserDetailsSheet({
  required BuildContext context,
  required Color color,
  required String title,
  required String subtitle,
  String confirmLabel = 'Confirm Booking',
  required void Function(String name, String email, String phone) onSuccess,
}) {
  final nameCtrl  = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final formKey   = GlobalKey<FormState>();

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
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.person_outline_rounded, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Your Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              ]),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),
              _FormField(
                controller: nameCtrl, label: 'Full Name', hint: 'As on government ID',
                icon: Icons.person_outline_rounded, color: color,
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  if (v.trim().length < 3) return 'Enter full name (min 3 chars)';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _FormField(
                controller: emailCtrl, label: 'Email Address', hint: 'Booking confirmation will be sent here',
                icon: Icons.email_outlined, color: color, keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _FormField(
                controller: phoneCtrl, label: 'Mobile Number', hint: '10-digit mobile number',
                icon: Icons.phone_outlined, color: color, keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Mobile number is required';
                  if (v.trim().length != 10) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      onSuccess(nameCtrl.text.trim(), emailCtrl.text.trim(), phoneCtrl.text.trim());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(confirmLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ✅ FIXED: onPayPressed is now async and saves to HistoryService
void showPaymentSheet({
  required BuildContext context,
  required Color color,
  required Map<String, dynamic> data,
  required String name,
  required String email,
  required String phone,
  required String dateStr,
  required int guests,
  required int total,
  String? confirmLabel,
}) {
  int selectedMethod = 0;
  int selectedUpiApp = 0;
  int selectedWallet = 0;

  final cardNumberCtrl = TextEditingController();
  final expiryCtrl     = TextEditingController();
  final cvvCtrl        = TextEditingController();
  final cardNameCtrl   = TextEditingController();
  final upiCtrl        = TextEditingController();
  final cardFormKey    = GlobalKey<FormState>();
  final upiFormKey     = GlobalKey<FormState>();

  final methods = [
    {'icon': Icons.credit_card_rounded,           'label': 'Card'},
    {'icon': Icons.qr_code_rounded,               'label': 'UPI'},
    {'icon': Icons.account_balance_rounded,        'label': 'Net Banking'},
    {'icon': Icons.account_balance_wallet_rounded, 'label': 'Wallet'},
  ];

  final upiApps = [
    {'name': 'GPay',    'color': const Color(0xFF5B2D8E), 'letter': 'G'},
    {'name': 'PhonePe', 'color': const Color(0xFF6739B7), 'letter': 'P'},
    {'name': 'Paytm',   'color': const Color(0xFF00BAF2), 'letter': 'P'},
    {'name': 'BHIM',    'color': const Color(0xFF002970), 'letter': 'B'},
  ];

  final wallets = [
    {'name': 'Paytm',    'color': const Color(0xFF00BAF2), 'letter': 'P'},
    {'name': 'Amazon',   'color': const Color(0xFFE8002D), 'letter': 'A'},
    {'name': 'Mobikwik', 'color': const Color(0xFFF05A28), 'letter': 'M'},
  ];

  final banks = ['State Bank of India', 'HDFC Bank', 'ICICI Bank', 'Axis Bank', 'Kotak Mahindra Bank'];
  String selectedBank = banks[0];

  // ✅ FIXED: async onPayPressed saves to HistoryService
  void onPayPressed(BuildContext ctx, StateSetter setS, String? label) async {
    bool valid = true;
    if (selectedMethod == 0) {
      valid = cardFormKey.currentState?.validate() ?? false;
    } else if (selectedMethod == 1) {
      valid = upiFormKey.currentState?.validate() ?? false;
    }
    if (!valid) return;

    Navigator.pop(ctx);

    // ✅ Save to HistoryService
    await HistoryService.instance.saveItem(
      HistoryService.makeLeisure(
        id: 'leisure_${DateTime.now().millisecondsSinceEpoch}',
        activityName: data['name'] as String,
        venue: (data['location'] ?? data['venue'] ?? '') as String,
        details: '$guests guest${guests == 1 ? '' : 's'} • $dateStr',
        amount: total.toDouble(),
        date: DateTime.now(),
      ),
    );

    final ref = 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    showBookingSuccessDialog(
      context: context,
      color: color,
      serviceIcon: data['icon'] as String,
      serviceName: data['name'] as String,
      bookingRef: ref,
      rows: [
        _InfoRow('Name', name),
        _InfoRow('Email', email),
        _InfoRow('Phone', phone),
        _InfoRow('Date', dateStr),
        _InfoRow('Guests', '$guests guest${guests == 1 ? '' : 's'}'),
        _InfoRow('Total', '₹$total', bold: true),
      ],
    );
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setS) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Row(children: [
                  Text(data['icon'] as String, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(data['name'] as String,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      Text('$guests guest${guests == 1 ? '' : 's'}  •  $dateStr  •  ₹$total',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                const Text('Select payment method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(methods.length, (i) {
                    final isActive = selectedMethod == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setS(() => selectedMethod = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: EdgeInsets.only(right: i < methods.length - 1 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive ? color.withValues(alpha: 0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isActive ? color : AppColors.border, width: isActive ? 1.5 : 1),
                          ),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(methods[i]['icon'] as IconData, size: 22,
                                color: isActive ? color : AppColors.textSecondary),
                            const SizedBox(height: 4),
                            Text(methods[i]['label'] as String,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                    color: isActive ? color : AppColors.textSecondary)),
                          ]),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                if (selectedMethod == 0) ...[
                  Form(
                    key: cardFormKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const _PayLabel('Card Number'),
                      _PayField(controller: cardNumberCtrl, hint: '1234  5678  9012  3456',
                          icon: Icons.credit_card_rounded, color: color, keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Card number is required';
                            if (v.trim().length < 16) return 'Enter valid 16-digit card number';
                            return null;
                          }),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const _PayLabel('Expiry'),
                          _PayField(controller: expiryCtrl, hint: 'MM / YY',
                              icon: Icons.calendar_today_rounded, color: color, keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                if (v.trim().length < 4) return 'MM/YY';
                                return null;
                              }),
                        ])),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const _PayLabel('CVV'),
                          _PayField(controller: cvvCtrl, hint: '•••',
                              icon: Icons.lock_outline_rounded, color: color, keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                if (v.trim().length < 3) return '3 digits';
                                return null;
                              }),
                        ])),
                      ]),
                      const SizedBox(height: 12),
                      const _PayLabel('Cardholder Name'),
                      _PayField(controller: cardNameCtrl, hint: 'Name on card',
                          icon: Icons.person_outline_rounded, color: color,
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Name is required';
                            return null;
                          }),
                    ]),
                  ),
                ],

                if (selectedMethod == 1) ...[
                  const Text('Quick pay via', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(upiApps.length, (i) {
                      final isActive = selectedUpiApp == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setS(() => selectedUpiApp = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: EdgeInsets.only(right: i < upiApps.length - 1 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive ? color.withValues(alpha: 0.06) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isActive ? color : AppColors.border, width: isActive ? 1.5 : 1),
                            ),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                width: 30, height: 30,
                                decoration: BoxDecoration(color: upiApps[i]['color'] as Color, borderRadius: BorderRadius.circular(8)),
                                child: Center(child: Text(upiApps[i]['letter'] as String,
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800))),
                              ),
                              const SizedBox(height: 4),
                              Text(upiApps[i]['name'] as String,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                      color: isActive ? color : AppColors.textSecondary)),
                            ]),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text('Or enter UPI ID', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Form(key: upiFormKey,
                    child: _PayField(controller: upiCtrl, hint: 'yourname@upi',
                        icon: Icons.alternate_email_rounded, color: color, keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          if (!v.contains('@')) return 'Enter valid UPI ID (e.g. name@upi)';
                          return null;
                        })),
                ],

                if (selectedMethod == 2) ...[
                  const Text('Select your bank', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedBank, isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: color),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        onChanged: (v) { if (v != null) setS(() => selectedBank = v); },
                        items: banks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      ),
                    ),
                  ),
                ],

                if (selectedMethod == 3) ...[
                  const Text('Select wallet', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(wallets.length, (i) {
                      final isActive = selectedWallet == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setS(() => selectedWallet = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: EdgeInsets.only(right: i < wallets.length - 1 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isActive ? color.withValues(alpha: 0.06) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isActive ? color : AppColors.border, width: isActive ? 1.5 : 1),
                            ),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                width: 30, height: 30,
                                decoration: BoxDecoration(color: wallets[i]['color'] as Color, borderRadius: BorderRadius.circular(8)),
                                child: Center(child: Text(wallets[i]['letter'] as String,
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800))),
                              ),
                              const SizedBox(height: 4),
                              Text(wallets[i]['name'] as String,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                      color: isActive ? color : AppColors.textSecondary)),
                            ]),
                          ),
                        ),
                      );
                    }),
                  ),
                ],

                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total payable', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text('₹$total', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => onPayPressed(ctx, setS, confirmLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text('Pay ₹$total Securely',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.verified_user_rounded, size: 13, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text('100% Secure Payment',
                        style: TextStyle(fontSize: 11, color: Colors.green[600], fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _PayLabel extends StatelessWidget {
  final String text;
  const _PayLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
  );
}

class _PayField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color color;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?) validator;

  const _PayField({
    required this.controller, required this.hint, required this.icon,
    required this.color, required this.validator,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller, keyboardType: keyboardType,
    textCapitalization: textCapitalization, inputFormatters: inputFormatters, validator: validator,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    decoration: InputDecoration(
      hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      filled: true, fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
    ),
  );
}

void showBookingSuccessDialog({
  required BuildContext context,
  required Color color,
  required String serviceIcon,
  required String serviceName,
  required String bookingRef,
  required List<_InfoRow> rows,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(children: [
              Text(serviceIcon, style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 32),
              const SizedBox(height: 6),
              const Text('Booking Confirmed!', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(serviceName, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              children: [
                ...rows.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(r.value, style: TextStyle(
                          fontSize: r.bold ? 14 : 12,
                          fontWeight: r.bold ? FontWeight.w800 : FontWeight.w600,
                          color: r.bold ? color : Colors.black87)),
                    ],
                  ),
                )),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Booking Ref', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(bookingRef, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _InfoRow {
  final String label, value;
  final bool bold;
  const _InfoRow(this.label, this.value, {this.bold = false});
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final Color color;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?) validator;

  const _FormField({
    required this.controller, required this.label, required this.hint,
    required this.icon, required this.color, required this.validator,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller, keyboardType: keyboardType,
        textCapitalization: textCapitalization, inputFormatters: inputFormatters, validator: validator,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
          filled: true, fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        ),
      ),
    ]);
  }
}

class _EmptyFilter extends StatelessWidget {
  final String filter;
  const _EmptyFilter({required this.filter});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(children: [
      const Text('🔍', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('No "$filter" listings right now', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      const Text('Try a different filter', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]),
  );
}

class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final String active;
  final ValueChanged<String> onSelect;
  const _FilterRow({required this.filters, required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) => SizedBox(
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : AppColors.textSecondary)),
          ),
        );
      },
    ),
  );
}

class _OfferBanner extends StatelessWidget {
  final String icon, title, subtitle;
  final Color color;
  const _OfferBanner({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.75)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 36)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Text('Grab', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
      ),
    ]),
  );
}

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
        color: Colors.white, borderRadius: BorderRadius.circular(20),
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
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 3),
                Expanded(child: Text(data['location'] as String,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ])),
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
              Expanded(child: Text(data['services'] as String,
                  style: TextStyle(fontSize: 11, color: tagColor, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                  Text('₹$price', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: tagColor)),
                  const SizedBox(width: 6),
                  if (originalPrice > price)
                    Text('₹$originalPrice', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary,
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
    int guests = 1;
    int selectedDateIdx = 0;
    final now = DateTime.now();
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          final total = pricePerPerson * guests;
          return Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Row(children: [
                Text(data['icon'] as String, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(data['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(data['location'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ])),
              ]),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Align(alignment: Alignment.centerLeft,
                  child: Text('Select Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
              const SizedBox(height: 10),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal, itemCount: 7,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final day = now.add(Duration(days: i));
                    final isSelected = i == selectedDateIdx;
                    return GestureDetector(
                      onTap: () => setS(() => selectedDateIdx = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180), width: 52,
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? color : AppColors.border),
                          boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))] : [],
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(dayNames[day.weekday - 1],
                              style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          Text('${day.day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : AppColors.textPrimary)),
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
                    onTap: () { if (guests > 1) setS(() => guests--); },
                    child: Container(width: 32, height: 32,
                        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.remove, size: 16))),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text('$guests', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                  GestureDetector(
                    onTap: () => setS(() => guests++),
                    child: Container(width: 32, height: 32,
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add, size: 16, color: Colors.white))),
                ]),
              ]),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('₹$total', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final selectedDay = now.add(Duration(days: selectedDateIdx));
                    Navigator.pop(context);
                    final dateStr = '${selectedDay.day} ${_monthShort(selectedDay.month)}';
                    showUserDetailsSheet(
                      context: context, color: color, title: 'Your Details',
                      subtitle: '${data['name']}  •  $guests guest${guests == 1 ? '' : 's'}  •  $dateStr  •  ₹$total',
                      onSuccess: (name, email, phone) {
                        showPaymentSheet(context: context, color: color, data: data,
                            name: name, email: email, phone: phone,
                            dateStr: dateStr, guests: guests, total: total);
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Continue', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ]),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _EventCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final tagColor = Color(data['tagColor'] as int);
    final price = data['price'] as int;
    final now = DateTime.now();
    final eventDate = now.add(Duration(days: (price % 6) + 1));
    const dayNames = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${dayNames[eventDate.weekday - 1]}, ${eventDate.day} ${months[eventDate.month - 1]} ${eventDate.year}';
    final dateShort = '${eventDate.day} ${months[eventDate.month - 1]}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 64, height: 64,
              decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(data['icon'] as String, style: const TextStyle(fontSize: 30)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(6)),
                child: Text(data['tag'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
              const SizedBox(width: 6),
              Text(data['category'] as String, style: TextStyle(fontSize: 10, color: tagColor, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 5),
            Text(data['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_rounded, size: 11, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Expanded(child: Text(data['venue'] as String,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                Text('₹$price', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: tagColor)),
                Text(data['seatsLeft'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ]),
              GestureDetector(
                onTap: () => _showTicketSheet(context, tagColor, price, dateShort),
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
          ])),
        ]),
      ),
    );
  }

  void _showTicketSheet(BuildContext context, Color color, int pricePerTicket, String dateShort) {
    int qty = 1;
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          final total = pricePerTicket * qty;
          return Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Row(children: [
                Text(data['icon'] as String, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(data['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  Text(data['venue'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
              ]),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Number of Tickets', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Row(children: [
                  GestureDetector(
                    onTap: () { if (qty > 1) setS(() => qty--); },
                    child: Container(width: 32, height: 32,
                        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.remove, size: 16))),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                  GestureDetector(
                    onTap: () => setS(() => qty++),
                    child: Container(width: 32, height: 32,
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add, size: 16, color: Colors.white))),
                ]),
              ]),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('₹$pricePerTicket × $qty ticket${qty > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  Text('₹$total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
                ]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showUserDetailsSheet(
                      context: context, color: color, title: 'Your Details',
                      subtitle: '${data['name']}  •  $qty ticket${qty == 1 ? '' : 's'}  •  $dateShort  •  ₹$total',
                      confirmLabel: 'Confirm & Get Tickets',
                      onSuccess: (name, email, phone) {
                        showPaymentSheet(context: context, color: color, data: data,
                            name: name, email: email, phone: phone,
                            dateStr: dateShort, guests: qty, total: total,
                            confirmLabel: 'Confirm & Get Tickets');
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Continue', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ]),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}