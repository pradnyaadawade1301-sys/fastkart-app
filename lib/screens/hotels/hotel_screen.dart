// lib/screens/hotels/hotel_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/mock_data.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});
  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  final hotels = mockHotels();
  String _sort = 'Rating';

  List<HotelModel> get sorted {
    final list = List<HotelModel>.from(hotels);
    if (_sort == 'Price Low') list.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
    if (_sort == 'Price High') list.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
    if (_sort == 'Rating') list.sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Hotel Booking', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded, color: Colors.black87),
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => ['Rating', 'Price Low', 'Price High']
                .map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
          ),
        ],
      ),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Row(children: [
            Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
            SizedBox(width: 6),
            Text('Mumbai', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            SizedBox(width: 16),
            Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 16),
            SizedBox(width: 6),
            Text('Check-in - Check-out', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (_, i) => _HotelCard(hotel: sorted[i]),
          ),
        ),
      ]),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final HotelModel hotel;
  const _HotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showHotelDetail(context, hotel),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(hotel.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 180, color: AppColors.divider,
                      child: const Icon(Icons.hotel, size: 48, color: AppColors.textHint))),
            ),
            if (!hotel.isAvailable)
              Positioned.fill(child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(color: Colors.black54,
                    child: const Center(child: Text('SOLD OUT',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 2)))),
              )),
            Positioned(top: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded, size: 12, color: AppColors.star),
                  Text(' ${hotel.rating}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              )),
          ]),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(hotel.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 3),
                Text(hotel.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Text('(${hotel.reviewCount} reviews)', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 4,
                children: hotel.amenities.map((a) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(a, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                )).toList(),
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Per Night', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('₹${hotel.pricePerNight}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.accent)),
                ]),
                Row(children: [
                  OutlinedButton(
                    onPressed: () => _showHotelDetail(context, hotel),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Reviews', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: hotel.isAvailable ? () => _showBookingSheet(context, hotel) : null,
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Book Now'),
                  ),
                ]),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showHotelDetail(BuildContext context, HotelModel hotel) {
    final reviews = [
      {'name': 'Rahul S.', 'rating': 5, 'comment': 'Excellent stay! Room was clean and service was top-notch.', 'date': '2 days ago'},
      {'name': 'Priya M.', 'rating': 4, 'comment': 'Great location and beautiful views. Breakfast was amazing.', 'date': '1 week ago'},
      {'name': 'Amit K.', 'rating': 5, 'comment': 'Perfect for our anniversary trip. Highly recommended!', 'date': '2 weeks ago'},
      {'name': 'Sneha P.', 'rating': 3, 'comment': 'Good hotel but room service was a bit slow.', 'date': '1 month ago'},
    ];

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(hotel.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.star, size: 16),
              Text(' ${hotel.rating}', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('  (${hotel.reviewCount} reviews)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            const Text('Guest Reviews', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(controller: ctrl, children: [
                ...reviews.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text((r['name'] as String)[0], style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary))),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(r['date'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                      ])),
                      Row(children: List.generate(5, (i) => Icon(Icons.star_rounded,
                          size: 12, color: i < (r['rating'] as int) ? AppColors.star : Colors.grey.shade300))),
                    ]),
                    const SizedBox(height: 8),
                    Text(r['comment'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                )),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: hotel.isAvailable ? () { Navigator.pop(context); _showBookingSheet(context, hotel); } : null,
                    child: const Text('Book Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  )),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _showBookingSheet(BuildContext context, HotelModel hotel) {
    int nights = 1;
    String roomType = 'Deluxe';
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String payment = 'UPI';
    int step = 0;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (step > 0) IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setS(() => step--)),
              Expanded(child: Text(step == 0 ? 'Select Room' : step == 1 ? 'Guest Details' : 'Confirm Booking',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
            const Divider(),
            Expanded(child: SingleChildScrollView(child: step == 0
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Room type
                  const Text('Room Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...['Deluxe', 'Super Deluxe', 'Suite'].map((rt) {
                    final prices = {'Deluxe': hotel.pricePerNight, 'Super Deluxe': (hotel.pricePerNight * 1.3).toInt(), 'Suite': (hotel.pricePerNight * 2).toInt()};
                    return GestureDetector(
                      onTap: () => setS(() => roomType = rt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: roomType == rt ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: roomType == rt ? AppColors.primary : AppColors.border, width: roomType == rt ? 2 : 1),
                        ),
                        child: Row(children: [
                          Icon(Icons.king_bed_rounded, color: roomType == rt ? AppColors.primary : AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Expanded(child: Text(rt, style: const TextStyle(fontWeight: FontWeight.w700))),
                          Text('₹${prices[rt]}/night', style: TextStyle(fontWeight: FontWeight.w800,
                              color: roomType == rt ? AppColors.accent : AppColors.textSecondary)),
                          if (roomType == rt) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                        ]),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Text('Number of Nights', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () { if (nights > 1) setS(() => nights--); }),
                    Text('$nights', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.primary), onPressed: () => setS(() => nights++)),
                    const Spacer(),
                    Text('₹${hotel.pricePerNight * nights}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.accent)),
                  ]),
                ])
              : step == 1
              ? Column(children: [
                  TextField(controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Guest Name', prefixIcon: Icon(Icons.person_rounded),
                        border: OutlineInputBorder())),
                  const SizedBox(height: 14),
                  TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_rounded),
                        border: OutlineInputBorder())),
                  const SizedBox(height: 20),
                  const Align(alignment: Alignment.centerLeft,
                    child: Text('Payment Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 10),
                  ...['UPI', 'Card', 'Net Banking', 'Pay at Hotel'].map((p) => GestureDetector(
                    onTap: () => setS(() => payment = p),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: payment == p ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: payment == p ? AppColors.primary : AppColors.border),
                      ),
                      child: Row(children: [
                        Text(p, style: TextStyle(fontWeight: FontWeight.w700,
                            color: payment == p ? AppColors.primary : Colors.black87)),
                        const Spacer(),
                        if (payment == p) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                      ]),
                    ),
                  )),
                ])
              : Column(children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                    child: Column(children: [
                      _confirmRow('Hotel', hotel.name),
                      _confirmRow('Room', roomType),
                      _confirmRow('Nights', '$nights night(s)'),
                      _confirmRow('Guest', nameCtrl.text.isEmpty ? 'Not provided' : nameCtrl.text),
                      _confirmRow('Mobile', phoneCtrl.text.isEmpty ? 'Not provided' : phoneCtrl.text),
                      _confirmRow('Payment', payment),
                      const Divider(height: 20),
                      _confirmRow('Total', '₹${hotel.pricePerNight * nights}', bold: true),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () { Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${hotel.name} booked for $nights night(s)! 🏨'),
                        backgroundColor: AppColors.success)); },
                    child: Container(height: 52, width: double.infinity,
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Text('Confirm & Pay ₹${hotel.pricePerNight * nights}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)))),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(height: 48, width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.5))),
                      child: const Center(child: Text('Cancel Booking',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error)))),
                  ),
                ]),
            )),
            if (step < 2)
              SizedBox(width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => setS(() => step++),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(step == 0 ? 'Continue' : 'Review Booking',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                )),
          ]),
        ),
      ),
    );
  }

  Widget _confirmRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            fontSize: bold ? 16 : 13, color: bold ? AppColors.accent : Colors.black87)),
      ]),
    );
  }
}