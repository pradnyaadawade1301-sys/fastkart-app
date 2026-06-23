// lib/screens/hotels/hotel_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/mock_data.dart';
import '../../services/history_service.dart';
import '../payment/payment_screen.dart';

// ── Local RoomOption model (HotelModel has no rooms list) ────────────────────
class _RoomOption {
  final String type;
  final double price;
  const _RoomOption({required this.type, required this.price});
}

List<_RoomOption> _roomsFor(HotelModel hotel) => [
  _RoomOption(type: 'Standard Room',  price: hotel.pricePerNight.toDouble()),
  _RoomOption(type: 'Deluxe Room',    price: hotel.pricePerNight * 1.4),
  _RoomOption(type: 'Suite',          price: hotel.pricePerNight * 2.0),
];

// ─────────────────────────────────────────────────────────────────────────────

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  HotelModel? _selectedHotel;
  _RoomOption? _selectedRoom;
  DateTime _checkIn  = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 3));
  int _guests = 2;
  bool _isBooking = false;

  final List<HotelModel> _hotels = mockHotels();

  int get _nights => _checkOut.difference(_checkIn).inDays.clamp(1, 30);
  double get _totalAmount => (_selectedRoom?.price ?? 0) * _nights;

  Future<void> _confirmBooking() async {
    if (_selectedHotel == null || _selectedRoom == null) return;
    setState(() => _isBooking = true);

    final orderId = 'HTL${DateTime.now().millisecondsSinceEpoch}';

    await HistoryService.instance.saveItem(
      HistoryService.makeHotel(
        id: orderId,
        hotelName: _selectedHotel!.name,
        city: _selectedHotel!.location,
        roomType: _selectedRoom!.type,
        nights: _nights,
        guests: _guests,
        amount: _totalAmount,
        checkIn: _checkIn,
        checkOut: _checkOut,
      ),
    );

    setState(() => _isBooking = false);
    if (!mounted) return;

    // Bottom sheet band karo
    Navigator.pop(context);

    // Payment screen pe navigate karo
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          amount: _totalAmount,
          orderId: orderId,
          authToken: '',
        ),
      ),
    );
  }

  void _showRoomPicker(HotelModel hotel) {
    setState(() {
      _selectedHotel = hotel;
      _selectedRoom = null;
    });
    final rooms = _roomsFor(hotel);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setBS) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(hotel.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              Text(hotel.location,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),

              // Check-in / Check-out
              Row(children: [
                Expanded(child: _dateCard('Check-in', _checkIn,
                    () async { await _pickDate(true); setBS(() {}); })),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('$_nights N',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Expanded(child: _dateCard('Check-out', _checkOut,
                    () async { await _pickDate(false); setBS(() {}); })),
              ]),
              const SizedBox(height: 12),

              // Guests
              Row(children: [
                const Text('Guests:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                _counterBtn(Icons.remove, () {
                  if (_guests > 1) { setState(() => _guests--); setBS(() {}); }
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('$_guests',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                _counterBtn(Icons.add, () {
                  setState(() => _guests++); setBS(() {});
                }),
              ]),
              const SizedBox(height: 16),

              const Text('Select Room',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),

              // Room options
              ...rooms.map((room) {
                final isSelected = _selectedRoom?.type == room.type;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedRoom = room);
                    setBS(() {});
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(children: [
                      Icon(Icons.king_bed_rounded,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(room.type,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary)),
                      ),
                      Text(
                        '₹${room.price.toStringAsFixed(0)}/night',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary),
                      ),
                    ]),
                  ),
                );
              }),

              const Divider(height: 24),
              if (_selectedRoom != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '₹${_selectedRoom!.price.toStringAsFixed(0)} × $_nights nights',
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                      Text('₹${_totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.primary)),
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: (_selectedRoom != null && !_isBooking)
                      ? _confirmBooking
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isBooking
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          _selectedRoom == null
                              ? 'Select a Room'
                              : 'Proceed to Payment — ₹${_totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateCard(String label, DateTime date, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text('${date.day}/${date.month}/${date.year}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
      );

  Widget _counterBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      );

  Future<void> _pickDate(bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkIn : _checkOut,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (_checkOut.isBefore(_checkIn.add(const Duration(days: 1)))) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hotels'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hotels.length,
        itemBuilder: (_, i) {
          final hotel = _hotels[i];
          return GestureDetector(
            onTap: () => _showRoomPicker(hotel),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: Image.network(
                      hotel.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180, color: AppColors.divider,
                        child: const Icon(Icons.hotel,
                            size: 48, color: AppColors.textHint),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(hotel.name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                            ),
                            Row(children: [
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFFFC107), size: 16),
                              const SizedBox(width: 4),
                              Text(hotel.rating.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(hotel.location,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ]),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'From ₹${hotel.pricePerNight}/night',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                  fontSize: 15),
                            ),
                            if (!hotel.isAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Text('Unavailable',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Text('Book Now',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}