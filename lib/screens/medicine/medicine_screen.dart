// lib/screens/medicine/medicine_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

const _moreServices = [
  {'name':'Doctor Consultation',  'location':'200+ specialist doctors', 'rating':'4.9','reviews':'18k', 'price':299, 'originalPrice':499, 'tag':'24/7',       'tagColor':0xFFFF6F00, 'desc':'Video • Chat • In-clinic visits',    'duration':'Available today', 'icon':'🧑‍⚕️', 'filter':'Health'},
  {'name':'Lab Tests at Home',    'location':'Home sample pickup',      'rating':'4.7','reviews':'9k',  'price':199, 'originalPrice':350, 'tag':'Home Visit', 'tagColor':0xFFE91E63, 'desc':'Blood • Urine • Full body checkup',  'duration':'Book by 8PM',     'icon':'🧪', 'filter':'Health'},
  {'name':'Mental Wellness',      'location':'Licensed therapists',     'rating':'4.8','reviews':'5.2k','price':399, 'originalPrice':599, 'tag':'Popular',    'tagColor':0xFF7C4DFF, 'desc':'Therapy • Counseling • Meditation', 'duration':'Same day slots',  'icon':'🧠', 'filter':'Health'},
  {'name':'Physiotherapy',        'location':'At-home or clinic',       'rating':'4.6','reviews':'3.1k','price':499, 'originalPrice':700, 'tag':'Expert',     'tagColor':0xFF00897B, 'desc':'Sports • Back pain • Rehab',        'duration':'45 min session',  'icon':'🦴', 'filter':'Health'},
  {'name':'Train Booking',        'location':'All India routes',        'rating':'4.5','reviews':'22k', 'price':199, 'originalPrice':0,   'tag':'IRCTC',      'tagColor':0xFF1565C0, 'desc':'Sleeper • AC • Express trains',     'duration':'Instant confirm', 'icon':'🚆', 'filter':'Travel'},
  {'name':'Bus Booking',          'location':'500+ operators',          'rating':'4.3','reviews':'11k', 'price':149, 'originalPrice':0,   'tag':'Popular',    'tagColor':0xFF2E7D32, 'desc':'AC • Sleeper • Volvo buses',        'duration':'Instant confirm', 'icon':'🚌', 'filter':'Travel'},
  {'name':'Cab Rental',           'location':'Outstation & local',      'rating':'4.7','reviews':'8.4k','price':999, 'originalPrice':1400,'tag':'Best Value', 'tagColor':0xFFFF9800, 'desc':'Sedan • SUV • Tempo Traveller',    'duration':'Per day rental',  'icon':'🚗', 'filter':'Travel'},
  {'name':'Online Tutoring',      'location':'Expert tutors',           'rating':'4.8','reviews':'6.7k','price':299, 'originalPrice':499, 'tag':'Live',       'tagColor':0xFF7C4DFF, 'desc':'Math • Science • English • Coding','duration':'60 min class',   'icon':'📚', 'filter':'Education'},
  {'name':'Skill Courses',        'location':'50+ categories',          'rating':'4.6','reviews':'14k', 'price':499, 'originalPrice':999, 'tag':'50% OFF',    'tagColor':0xFFE91E63, 'desc':'Design • Finance • Marketing',     'duration':'Self-paced',      'icon':'🎓', 'filter':'Education'},
  {'name':'Language Classes',     'location':'Native instructors',      'rating':'4.7','reviews':'3.8k','price':399, 'originalPrice':599, 'tag':'New',        'tagColor':0xFF00897B, 'desc':'English • French • Spanish • Hindi','duration':'45 min/session', 'icon':'🗣️', 'filter':'Education'},
];

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});
  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = [
    {'label': 'All'},
    {'label': 'Health'},
    {'label': 'Travel'},
    {'label': 'Education'},
  ];

  static const _headerColor = Color(0xFF455A64);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
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
            expandedHeight: 180,
            backgroundColor: _headerColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: _headerColor,
                child: Stack(children: [
                  Positioned(
                    top: -20, right: -20,
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  const SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 8),
                          Text('⭐', style: TextStyle(fontSize: 52)),
                          SizedBox(height: 6),
                          Text('More Services',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                          SizedBox(height: 4),
                          Text('Everything else you need',
                              style: TextStyle(fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            // ✅ FIX 1: Tabs evenly spread across full width
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: _headerColor,
                child: TabBar(
                  controller: _tabCtrl,
                  isScrollable: false,          // ✅ false = full width mein spread
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: _tabs.map((t) => _MoreTab(filter: t['label']!)).toList(),
        ),
      ),
    );
  }
}

class _MoreTab extends StatefulWidget {
  final String filter;
  const _MoreTab({required this.filter});
  @override
  State<_MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<_MoreTab> {
  String _active = 'All';

  List<String> get _filters {
    final all = ['All'];
    for (final s in _moreServices) {
      final f = s['filter'] as String;
      if (!all.contains(f)) all.add(f);
    }
    return all;
  }

  List<Map<String, dynamic>> get _items {
    final list = List<Map<String, dynamic>>.from(_moreServices);
    if (widget.filter != 'All') return list.where((s) => s['filter'] == widget.filter).toList();
    if (_active != 'All') return list.where((s) => s['filter'] == _active).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.filter == 'All')
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const _StatBodyItem(value: '20+', label: 'Services', color: Color(0xFF455A64)),
                Container(width: 1, height: 32, color: Colors.grey.shade200),
                const _StatBodyItem(value: '1M+', label: 'Users', color: Color(0xFF455A64)),
                Container(width: 1, height: 32, color: Colors.grey.shade200),
                const _StatBodyItemStar(value: '4.7'),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF455A64),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: const Color(0xFF455A64).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            const Text('🚀', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Explore new services!', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              Text('Use code: EXPLORE', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: const Text('Grab', style: TextStyle(color: Color(0xFF455A64), fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        if (widget.filter == 'All') ...[
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final isActive = f == _active;
                return GestureDetector(
                  onTap: () => setState(() => _active = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF455A64) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isActive ? const Color(0xFF455A64) : AppColors.border),
                    ),
                    child: Text(f, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : AppColors.textSecondary)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        ..._items.map((s) => _ServiceCard(data: s)),
      ],
    );
  }
}

// ✅ FIX 2: Book Now pe appointment bottom sheet
class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ServiceCard({required this.data});

  void _showBookingSheet(BuildContext context) {
    final tagColor = Color(data['tagColor'] as int);
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    String selectedDate = '';
    String selectedTime = '';
    final formKey = GlobalKey<FormState>();

    final dates = _nextDates();
    final times = ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(data['icon'] as String, style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(data['name'] as String,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      Text('₹${data['price']} per person',
                          style: TextStyle(fontSize: 12, color: tagColor, fontWeight: FontWeight.w700)),
                    ])),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close_rounded, size: 22),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(data['desc'] as String,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const Divider(height: 24),

                  // Full Name
                  const Text('Full Name',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDeco('Enter your name', Icons.person_outline_rounded, tagColor),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Phone
                  const Text('Phone Number',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: _inputDeco('10 digit mobile number', Icons.phone_outlined, tagColor),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Phone number is required';
                      if (v.trim().length < 10) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Age
                  const Text('Age',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: ageCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    decoration: _inputDeco('Enter your age', Icons.cake_outlined, tagColor),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Age is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Date select
                  const Text('Appointment Date',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final d = dates[i];
                        final isSelected = d == selectedDate;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedDate = d),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? tagColor : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? tagColor : AppColors.border),
                            ),
                            child: Text(d,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : AppColors.textSecondary)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Time select
                  const Text('Time Slot',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: times.map((t) {
                      final isSelected = t == selectedTime;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedTime = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? tagColor : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? tagColor : AppColors.border),
                          ),
                          child: Text(t,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : AppColors.textSecondary)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        if (selectedDate.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a date'), behavior: SnackBarBehavior.floating));
                          return;
                        }
                        if (selectedTime.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a time slot'), behavior: SnackBarBehavior.floating));
                          return;
                        }
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('✅ ${data['name']} — Booked for $selectedDate $selectedTime!'),
                          backgroundColor: tagColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 3),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF455A64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Confirm Appointment →',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> _nextDates() {
    final now = DateTime.now();
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return List.generate(6, (i) {
      final d = now.add(Duration(days: i));
      final label = i == 0 ? 'Today' : i == 1 ? 'Tomorrow' : '${days[d.weekday % 7]}, ${d.day} ${months[d.month - 1]}';
      return label;
    });
  }

  InputDecoration _inputDeco(String hint, IconData icon, Color color) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      filled: true,
      fillColor: const Color(0xFFF2F2F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.error)),
      counterText: '',
    );
  }

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
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(data['icon'] as String, style: const TextStyle(fontSize: 30))),
            ),
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
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                Text(' ${data['rating']}  (${data['reviews']})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ]),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(8)),
              child: Text(data['tag'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.medical_services_rounded, size: 13, color: tagColor),
              const SizedBox(width: 5),
              Expanded(child: Text(data['desc'] as String,
                  style: TextStyle(fontSize: 11, color: tagColor, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.timer_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(data['duration'] as String,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('₹$price', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: tagColor)),
                  const SizedBox(width: 6),
                  if (originalPrice > 0)
                    Text('₹$originalPrice', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough)),
                ]),
                const Text('per person', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ]),
              // ✅ Book Now — ab appointment bottom sheet khulega
              GestureDetector(
                onTap: () => _showBookingSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF455A64),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: const Color(0xFF455A64).withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
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

class _StatBodyItem extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatBodyItem({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  ]);
}

class _StatBodyItemStar extends StatelessWidget {
  final String value;
  const _StatBodyItemStar({required this.value});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Row(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF455A64))),
      const SizedBox(width: 3),
      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
    ]),
    const SizedBox(height: 2),
    const Text('Rating', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  ]);
}