// lib/screens/grocery/grocery_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

// ─── DATA ─────────────────────────────────────────────────────────────────────

const _groceryItems = [
  // Vegetables
  {'id':'g1',  'name':'Fresh Tomatoes',  'source':'Local farm sourced',  'rating':'4.7','reviews':'2.1k','price':40,  'originalPrice':60,  'tag':'Fresh',      'tagColor':0xFF2E7D32, 'desc':'Farm fresh • Organic • 1 kg',    'duration':'10 min', 'icon':'🍅', 'filter':'Vegetables'},
  {'id':'g2',  'name':'Onions',          'source':'Nashik farms',         'rating':'4.5','reviews':'3.2k','price':35,  'originalPrice':0,   'tag':'Daily Fresh','tagColor':0xFF00897B, 'desc':'Farm sourced • Sorted • 1 kg',  'duration':'10 min', 'icon':'🧅', 'filter':'Vegetables'},
  {'id':'g3',  'name':'Potatoes',        'source':'UP farms',             'rating':'4.4','reviews':'4.5k','price':30,  'originalPrice':0,   'tag':'Bestseller', 'tagColor':0xFF6D4C41, 'desc':'Washed & cleaned • 1 kg',      'duration':'10 min', 'icon':'🥔', 'filter':'Vegetables'},
  {'id':'g4',  'name':'Spinach',         'source':'Local farm',           'rating':'4.6','reviews':'1.8k','price':25,  'originalPrice':40,  'tag':'Organic',    'tagColor':0xFF388E3C, 'desc':'Tender leaves • 500g bunch',    'duration':'10 min', 'icon':'🥬', 'filter':'Vegetables'},
  // Fruits
  {'id':'g5',  'name':'Bananas',         'source':'Kerala farms',         'rating':'4.8','reviews':'5.6k','price':60,  'originalPrice':80,  'tag':'Popular',    'tagColor':0xFFF9A825, 'desc':'Ripe & sweet • 1 dozen',        'duration':'10 min', 'icon':'🍌', 'filter':'Fruits'},
  {'id':'g6',  'name':'Apples (Shimla)', 'source':'Himachal farms',       'rating':'4.7','reviews':'3.4k','price':120, 'originalPrice':150, 'tag':'Premium',    'tagColor':0xFFE53935, 'desc':'Crispy & fresh • 1 kg',         'duration':'10 min', 'icon':'🍎', 'filter':'Fruits'},
  {'id':'g7',  'name':'Mangoes (Alphonso)','source':'Ratnagiri, Maharashtra','rating':'4.9','reviews':'2.1k','price':280,'originalPrice':350,'tag':'Seasonal',  'tagColor':0xFFFF6F00, 'desc':'King of fruits • 1 kg',         'duration':'10 min', 'icon':'🥭', 'filter':'Fruits'},
  // Dairy
  {'id':'g8',  'name':'Full Cream Milk', 'source':'Amul dairy',           'rating':'4.8','reviews':'8.9k','price':65,  'originalPrice':0,   'tag':'Daily Fresh','tagColor':0xFF1E88E5, 'desc':'Pasteurized • 1 litre',         'duration':'10 min', 'icon':'🥛', 'filter':'Dairy'},
  {'id':'g9',  'name':'Paneer',          'source':'Mother Dairy',         'rating':'4.7','reviews':'5.1k','price':85,  'originalPrice':100, 'tag':'Fresh',      'tagColor':0xFF00897B, 'desc':'Soft & fresh • 200g',           'duration':'10 min', 'icon':'🧀', 'filter':'Dairy'},
  {'id':'g10', 'name':'Curd',            'source':'Nestle farms',         'rating':'4.6','reviews':'3.8k','price':45,  'originalPrice':0,   'tag':'Probiotic',  'tagColor':0xFF8E24AA, 'desc':'Thick & creamy • 400g',         'duration':'10 min', 'icon':'🫙', 'filter':'Dairy'},
  // Staples
  {'id':'g11', 'name':'Basmati Rice',    'source':'Punjab farms',         'rating':'4.8','reviews':'6.7k','price':450, 'originalPrice':520, 'tag':'Premium',    'tagColor':0xFFFF8F00, 'desc':'Long grain • Extra fragrant • 5kg','duration':'10 min','icon':'🍚','filter':'Staples'},
  {'id':'g12', 'name':'Toor Dal',        'source':'Maharashtra farms',    'rating':'4.5','reviews':'3.1k','price':140, 'originalPrice':0,   'tag':'Clean',      'tagColor':0xFFE65100, 'desc':'Clean & sorted • 1 kg',         'duration':'10 min', 'icon':'🫘', 'filter':'Staples'},
  {'id':'g13', 'name':'Sunflower Oil',   'source':'Marico',               'rating':'4.4','reviews':'2.8k','price':130, 'originalPrice':150, 'tag':'Refined',    'tagColor':0xFFFDD835, 'desc':'Refined • Heart healthy • 1L',  'duration':'10 min', 'icon':'🫒', 'filter':'Staples'},
];

// ─── SCREEN ───────────────────────────────────────────────────────────────────

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});
  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  static const _tabFilters = ['All', 'Vegetables', 'Fruits', 'Dairy', 'Staples'];
  String _activeFilter = 'All';

  // qty map — default 0 for all items
  final Map<String, int> _qty = {};

  int get _cartCount => _qty.values.fold(0, (s, v) => s + v);
  double get _cartTotal => _groceryItems.fold(0.0, (s, item) {
    final q = _qty[item['id'] as String] ?? 0;
    return s + (item['price'] as int) * q;
  });

  List<Map<String, dynamic>> get _filtered {
    final list = List<Map<String, dynamic>>.from(_groceryItems);
    if (_activeFilter == 'All') return list;
    return list.where((i) => i['filter'] == _activeFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabFilters.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _activeFilter = _tabFilters[_tabCtrl.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  static const _headerColor = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: _headerColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (_cartCount > 0)
                Stack(children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white),
                    onPressed: _showCart,
                  ),
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Center(child: Text('$_cartCount',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
                    ),
                  ),
                ]),
            ],
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
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        const Text('🏷️', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 6),
                        const Text('grocery',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 4),
                        const Text('Explore grocery',
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
                              const _StatItem(value: '100+', label: 'Options'),
                              Container(width: 1, height: 32, color: Colors.white30),
                              const _StatItem(value: '50K+', label: 'Users'),
                              Container(width: 1, height: 32, color: Colors.white30),
                              const _StatItemWithStar(value: '4.5', label: 'Rating'),
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
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: _headerColor,
                child: TabBar(
                  controller: _tabCtrl,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  tabs: _tabFilters.map((t) => Tab(text: t)).toList(),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: _tabFilters.map((filter) {
            return _GroceryTab(
              filter: filter,
              qty: _qty,
              onAdd: (id) => setState(() => _qty[id] = (_qty[id] ?? 0) + 1),
              onRemove: (id) => setState(() {
                if ((_qty[id] ?? 0) > 0) _qty[id] = (_qty[id]! - 1);
              }),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: _cartCount > 0
          ? GestureDetector(
              onTap: _showCart,
              child: Container(
                height: 60,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: _headerColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: _headerColor.withValues(alpha: 0.4), blurRadius: 12)],
                ),
                child: Row(children: [
                  const SizedBox(width: 16),
                  Container(
                    width: 30, height: 30,
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: Center(child: Text('$_cartCount',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
                  ),
                  const SizedBox(width: 10),
                  const Text('View Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('₹${_cartTotal.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(width: 16),
                ]),
              ),
            )
          : null,
    );
  }

  void _showCart() {
    final cartItems = _groceryItems.where((i) => (_qty[i['id'] as String] ?? 0) > 0).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Row(children: [
              const Text('Your Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
            const Divider(),
            Expanded(child: ListView(children: [
              ...cartItems.map((item) {
                final id = item['id'] as String;
                final q = _qty[id] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: Color((item['tagColor'] as int)).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(item['icon'] as String, style: const TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(item['desc'] as String,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ])),
                    Row(children: [
                      GestureDetector(
                        onTap: () { setS(() { setState(() { if (q > 0) _qty[id] = q - 1; }); }); },
                        child: Container(width: 26, height: 26,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _headerColor)),
                            child: const Icon(Icons.remove, size: 13, color: _headerColor)),
                      ),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('$q', style: const TextStyle(fontWeight: FontWeight.w800))),
                      GestureDetector(
                        onTap: () { setS(() { setState(() { _qty[id] = q + 1; }); }); },
                        child: Container(width: 26, height: 26,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: _headerColor),
                            child: const Icon(Icons.add, size: 13, color: Colors.white)),
                      ),
                    ]),
                    const SizedBox(width: 10),
                    Text('₹${((item['price'] as int) * q)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: _headerColor)),
                  ]),
                );
              }),
              const Divider(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary)),
                Text('₹${_cartTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Delivery', style: TextStyle(color: AppColors.textSecondary)),
                Text(_cartTotal >= 299 ? 'FREE' : '₹29',
                    style: TextStyle(fontWeight: FontWeight.w700,
                        color: _cartTotal >= 299 ? AppColors.success : AppColors.textPrimary)),
              ]),
              const Divider(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text('₹${(_cartTotal + (_cartTotal >= 299 ? 0 : 29)).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _headerColor)),
              ]),
            ])),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                // ── CHANGE 2: Place Order opens user details form ──
                onPressed: () {
                  Navigator.pop(context);
                  _showUserDetailsForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _headerColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Place Order', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── User Details Form ──────────────────────────────────────────────────────
  void _showUserDetailsForm() {
    final nameCtrl    = TextEditingController();
    final phoneCtrl   = TextEditingController();
    final addressCtrl = TextEditingController();
    final pinCtrl     = TextEditingController();
    final formKey     = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // Header
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: _headerColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.person_rounded, color: _headerColor, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Delivery Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  Text('Please fill your delivery details', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ]),
              const SizedBox(height: 20),

              // Name field
              _buildTextField(
                controller: nameCtrl,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 14),

              // Phone field
              _buildTextField(
                controller: phoneCtrl,
                label: 'Mobile Number',
                hint: '10 digit number',
                icon: Icons.phone_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone number is required';
                  if (v.trim().length != 10) return 'Enter a valid 10-digit number';
                  return null;
                },
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
              const SizedBox(height: 14),

              // Address field
              _buildTextField(
                controller: addressCtrl,
                label: 'Delivery Address',
                hint: 'House/flat no., street, area',
                icon: Icons.home_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 14),

              // PIN code field
              _buildTextField(
                controller: pinCtrl,
                label: 'PIN Code',
                hint: '6-digit PIN code',
                icon: Icons.location_on_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'PIN code is required';
                  if (v.trim().length != 6) return 'Enter a valid 6-digit PIN';
                  return null;
                },
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 24),

              // Confirm Order button
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('✅ Order confirmed! Delivering to ${nameCtrl.text} in 10 mins'),
                        backgroundColor: const Color(0xFF2E7D32),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 3),
                      ));
                      setState(() => _qty.clear());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _headerColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Confirm Order', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: _headerColor),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _headerColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}

// ─── TAB CONTENT ──────────────────────────────────────────────────────────────

class _GroceryTab extends StatelessWidget {
  final String filter;
  final Map<String, int> qty;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _GroceryTab({
    required this.filter,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  List<Map<String, dynamic>> get _items {
    final list = List<Map<String, dynamic>>.from(_groceryItems);
    if (filter == 'All') return list;
    return list.where((i) => i['filter'] == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final subFilters = <String>['All'];
    for (final i in _items) {
      final f = i['filter'] as String;
      if (!subFilters.contains(f)) subFilters.add(f);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Offer banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF00897B),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: const Color(0xFF00897B).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            const Text('🛒', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Free delivery on ₹299+', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              Text('Use code: FRESHKART', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: const Text('Grab', style: TextStyle(color: Color(0xFF00897B), fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Filter chips (only show in All tab)
        if (filter == 'All') ...[
          SizedBox(
            height: 38,
            child: _FilterChips(filters: subFilters),
          ),
          const SizedBox(height: 16),
        ],

        // Item cards
        ..._items.map((item) => _GroceryCard(
          item: item,
          // ── CHANGE 1: default qty is 0 (from map, unset = 0) ──
          qty: qty[item['id'] as String] ?? 0,
          onAdd: () => onAdd(item['id'] as String),
          onRemove: () => onRemove(item['id'] as String),
        )),
      ],
    );
  }
}

class _FilterChips extends StatefulWidget {
  final List<String> filters;
  const _FilterChips({required this.filters});
  @override
  State<_FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<_FilterChips> {
  String _active = 'All';
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: widget.filters.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final f = widget.filters[i];
        final isActive = f == _active;
        return GestureDetector(
          onTap: () => setState(() => _active = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFE65100) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isActive ? const Color(0xFFE65100) : AppColors.border),
            ),
            child: Text(f,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : AppColors.textSecondary)),
          ),
        );
      },
    );
  }
}

// ─── GROCERY CARD ─────────────────────────────────────────────────────────────

class _GroceryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int qty;
  final VoidCallback onAdd, onRemove;

  const _GroceryCard({required this.item, required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final tagColor = Color(item['tagColor'] as int);
    final price = item['price'] as int;
    final originalPrice = item['originalPrice'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header section
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            color: tagColor.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(item['icon'] as String, style: const TextStyle(fontSize: 32))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['name'] as String,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(item['source'] as String,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                  Text(' ${item['rating']}  (${item['reviews']})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                ]),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(8)),
                child: Text(item['tag'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ]),
          ]),
        ),

        // Details section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.eco_rounded, size: 13, color: tagColor),
              const SizedBox(width: 5),
              Text(item['desc'] as String,
                  style: TextStyle(fontSize: 11, color: tagColor, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.timer_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(item['duration'] as String,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('₹$price',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: tagColor)),
                  const SizedBox(width: 6),
                  if (originalPrice > 0)
                    Text('₹$originalPrice',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough)),
                ]),
                const Text('per person', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ]),
              // ── CHANGE 1: Hamesha - 0 + counter dikhao (Book Now button hataaya) ──
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 36, height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                      ),
                      child: const Icon(Icons.remove, size: 18, color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    // Shows 0 by default, increments on +
                    child: Text('$qty', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      width: 36, height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                      ),
                      child: const Icon(Icons.add, size: 18, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ─── STAT WIDGETS ─────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
    ]);
  }
}

class _StatItemWithStar extends StatelessWidget {
  final String value, label;
  const _StatItemWithStar({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(width: 3),
        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
      ]),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
    ]);
  }
}