// lib/screens/offers/offers_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class OfferModel {
  final String id, code, title, description, category;
  final int discount, minOrder;
  final bool isPercent, isCashback;
  final DateTime expiry;
  bool isUsed;

  OfferModel({
    required this.id, required this.code, required this.title,
    required this.description, required this.category,
    required this.discount, required this.minOrder,
    this.isPercent = true, this.isCashback = false,
    required this.expiry, this.isUsed = false,
  });
}

List<OfferModel> _mockOffers() => [
  OfferModel(id:'o1', code:'FIRST50', title:'50% OFF on First Order', description:'Get 50% off on your first food order. Max discount ₹100.', category:'Food', discount:50, minOrder:199, expiry:DateTime.now().add(const Duration(days:30))),
  OfferModel(id:'o2', code:'FREEDOM20', title:'20% OFF on All Orders', description:'Special Independence Day offer. 20% off on all categories.', category:'All', discount:20, minOrder:299, expiry:DateTime.now().add(const Duration(days:7))),
  OfferModel(id:'o3', code:'MOVIE100', title:'₹100 OFF on Movie Tickets', description:'Save ₹100 on movie ticket bookings above ₹500.', category:'Movies', discount:100, minOrder:500, isPercent:false, expiry:DateTime.now().add(const Duration(days:14))),
  OfferModel(id:'o4', code:'FLYCHEAP', title:'15% OFF on Flights', description:'Book flights and save 15%. Valid on all airlines.', category:'Flights', discount:15, minOrder:2000, expiry:DateTime.now().add(const Duration(days:20))),
  OfferModel(id:'o5', code:'CASHBACK10', title:'10% Cashback on UPI', description:'Pay via UPI and get 10% cashback in your wallet.', category:'All', discount:10, minOrder:100, isCashback:true, expiry:DateTime.now().add(const Duration(days:10))),
  OfferModel(id:'o6', code:'HOTEL25', title:'25% OFF on Hotels', description:'Weekend special - 25% off on hotel bookings.', category:'Hotels', discount:25, minOrder:1000, expiry:DateTime.now().add(const Duration(days:3))),
  OfferModel(id:'o7', code:'GROCERY15', title:'15% OFF on Groceries', description:'Fresh savings on your grocery orders.', category:'Grocery', discount:15, minOrder:299, expiry:DateTime.now().add(const Duration(days:5))),
  OfferModel(id:'o8', code:'NEWUSER', title:'₹200 OFF for New Users', description:'Welcome offer for new FastKart users.', category:'All', discount:200, minOrder:499, isPercent:false, expiry:DateTime.now().add(const Duration(days:60))),
];

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});
  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final offers = _mockOffers();
  String _cat = 'All';
  final cats = ['All', 'Food', 'Movies', 'Flights', 'Hotels', 'Grocery'];
  int _points = 1280;

  List<OfferModel> get _filtered =>
      _cat == 'All' ? offers : offers.where((o) => o.category == _cat || o.category == 'All').toList();

  Color _catColor(String cat) {
    switch (cat) {
      case 'Food': return AppColors.catFood;
      case 'Movies': return AppColors.catMovie;
      case 'Flights': return const Color(0xFFFF9800);
      case 'Hotels': return AppColors.catHotel;
      case 'Grocery': return AppColors.catGrocery;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Offers & Rewards 🎁', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        children: [
          // Points card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFB300)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Your Points', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('$_points pts', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('= ₹12.80 value', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('⭐', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showRedeemPoints(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Redeem', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12)),
                  ),
                ),
              ]),
            ]),
          ),

          // Cashback promo
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: const Row(children: [
              Text('💰', style: TextStyle(fontSize: 28)),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Earn Cashback!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                Text('Pay via UPI & earn 10% cashback on every order', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
            ]),
          ),

          const SizedBox(height: 16),

          // Category filter
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cats.length,
              itemBuilder: (_, i) {
                final active = cats[i] == _cat;
                return GestureDetector(
                  onTap: () => setState(() => _cat = cats[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(cats[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: active ? Colors.black87 : AppColors.textSecondary)),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Offers list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: _filtered.map((offer) {
              final daysLeft = offer.expiry.difference(DateTime.now()).inDays;
              final color = _catColor(offer.category);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
                ),
                child: Column(children: [
                  // Header strip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                        child: Text(offer.code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                      ),
                      const Spacer(),
                      if (offer.isCashback)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(6)),
                          child: const Text('CASHBACK', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
                      if (daysLeft <= 3)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                          child: Text('${daysLeft}d left', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
                    ]),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(offer.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
                        Text(offer.isPercent ? '${offer.discount}% OFF' : '₹${offer.discount} OFF',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
                      ]),
                      const SizedBox(height: 4),
                      Text(offer.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Text('Min order: ₹${offer.minOrder}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                        const Spacer(),
                        Text('Expires: ${offer.expiry.day}/${offer.expiry.month}/${offer.expiry.year}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                      ]),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _copyCode(offer.code),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withValues(alpha: 0.3), style: BorderStyle.solid),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.copy_rounded, size: 14, color: color),
                            const SizedBox(width: 6),
                            Text('Copy Code: ${offer.code}', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ]),
              );
            }).toList()),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _copyCode(String code) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Code "$code" copied! Use it at checkout.'),
      backgroundColor: AppColors.success,
      action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
    ));
  }

  void _showRedeemPoints() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Redeem Points', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('You have $_points points = ₹${(_points * 0.01).toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ...[100, 250, 500, 1000].where((p) => p <= _points).map((p) => GestureDetector(
            onTap: () {
              setState(() { _points -= p; });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$p points redeemed = ₹${(p * 0.01).toStringAsFixed(2)} wallet credit!'),
                backgroundColor: AppColors.success));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Text('⭐', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(child: Text('Redeem $p points', style: const TextStyle(fontWeight: FontWeight.w700))),
                Text('= ₹${(p * 0.01).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.accent)),
              ]),
            ),
          )),
        ]),
      ),
    );
  }
}