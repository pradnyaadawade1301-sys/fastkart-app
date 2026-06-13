// lib/screens/flights/flights_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class FlightModel {
  final String id, airline, airlineLogo, flightNumber;
  final String from, fromCode, to, toCode;
  final String departure, arrival, duration;
  final int price, seatsLeft;
  final String classType;
  final bool isNonstop;

  const FlightModel({
    required this.id, required this.airline, required this.airlineLogo,
    required this.flightNumber, required this.from, required this.fromCode,
    required this.to, required this.toCode, required this.departure,
    required this.arrival, required this.duration, required this.price,
    required this.seatsLeft, required this.classType, required this.isNonstop,
  });
}

List<FlightModel> mockFlights() => [
  const FlightModel(id:'f1', airline:'IndiGo', airlineLogo:'6E', flightNumber:'6E-2341', from:'Mumbai', fromCode:'BOM', to:'Delhi', toCode:'DEL', departure:'06:00 AM', arrival:'08:15 AM', duration:'2h 15m', price:3499, seatsLeft:12, classType:'Economy', isNonstop:true),
  const FlightModel(id:'f2', airline:'Air India', airlineLogo:'AI', flightNumber:'AI-865', from:'Mumbai', fromCode:'BOM', to:'Delhi', toCode:'DEL', departure:'08:30 AM', arrival:'10:50 AM', duration:'2h 20m', price:4299, seatsLeft:24, classType:'Economy', isNonstop:true),
  const FlightModel(id:'f3', airline:'Vistara', airlineLogo:'UK', flightNumber:'UK-955', from:'Mumbai', fromCode:'BOM', to:'Bangalore', toCode:'BLR', departure:'10:15 AM', arrival:'11:45 AM', duration:'1h 30m', price:3899, seatsLeft:8, classType:'Economy', isNonstop:true),
  const FlightModel(id:'f4', airline:'SpiceJet', airlineLogo:'SG', flightNumber:'SG-8169', from:'Mumbai', fromCode:'BOM', to:'Chennai', toCode:'MAA', departure:'01:00 PM', arrival:'03:00 PM', duration:'2h 00m', price:2999, seatsLeft:31, classType:'Economy', isNonstop:true),
  const FlightModel(id:'f5', airline:'IndiGo', airlineLogo:'6E', flightNumber:'6E-5317', from:'Mumbai', fromCode:'BOM', to:'Kolkata', toCode:'CCU', departure:'03:45 PM', arrival:'06:30 PM', duration:'2h 45m', price:4799, seatsLeft:5, classType:'Economy', isNonstop:true),
  const FlightModel(id:'f6', airline:'Air India', airlineLogo:'AI', flightNumber:'AI-102', from:'Mumbai', fromCode:'BOM', to:'Hyderabad', toCode:'HYD', departure:'06:20 PM', arrival:'07:50 PM', duration:'1h 30m', price:3299, seatsLeft:18, classType:'Economy', isNonstop:true),
  const FlightModel(id:'f7', airline:'Vistara', airlineLogo:'UK', flightNumber:'UK-201', from:'Mumbai', fromCode:'BOM', to:'Goa', toCode:'GOI', departure:'08:00 AM', arrival:'09:10 AM', duration:'1h 10m', price:2499, seatsLeft:22, classType:'Economy', isNonstop:true),
  const FlightModel(id:'f8', airline:'IndiGo', airlineLogo:'6E', flightNumber:'6E-1143', from:'Mumbai', fromCode:'BOM', to:'Pune', toCode:'PNQ', departure:'11:30 AM', arrival:'12:20 PM', duration:'0h 50m', price:1899, seatsLeft:40, classType:'Economy', isNonstop:true),
];

class FlightsScreen extends StatefulWidget {
  const FlightsScreen({super.key});
  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> {
  final flights = mockFlights();
  String _sort = 'Price';
  String _filterAirline = 'All';
  final List<Map<String, dynamic>> _myBookings = [];
  final airlines = ['All', 'IndiGo', 'Air India', 'Vistara', 'SpiceJet'];

  List<FlightModel> get filtered {
    var list = List<FlightModel>.from(flights);
    if (_filterAirline != 'All') list = list.where((f) => f.airline == _filterAirline).toList();
    if (_sort == 'Price') list.sort((a, b) => a.price.compareTo(b.price));
    if (_sort == 'Duration') list.sort((a, b) => a.duration.compareTo(b.duration));
    if (_sort == 'Departure') list.sort((a, b) => a.departure.compareTo(b.departure));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('Flight Booking ✈️', style: TextStyle(fontWeight: FontWeight.w800)),
          leading: BackButton(onPressed: () => Navigator.pop(context)),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort_rounded, color: Colors.black87),
              onSelected: (v) => setState(() => _sort = v),
              itemBuilder: (_) => ['Price', 'Duration', 'Departure']
                  .map((s) => PopupMenuItem(value: s, child: Text('Sort by $s'))).toList(),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.black87,
            tabs: [Tab(text: 'Search Flights'), Tab(text: 'My Bookings')],
          ),
        ),
        body: TabBarView(children: [
          _searchTab(),
          _bookingsTab(),
        ]),
      ),
    );
  }

  Widget _searchTab() {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('From', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text('Mumbai', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Text('BOM', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
          ])),
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 22)),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('To', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text('Any', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Text('All Routes', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
          ])),
        ]),
      ),

      Container(
        color: const Color(0xFFF8F5F0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: const Row(children: [
          Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 6),
          Text('Today, 9 Jun 2026', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Spacer(),
          Icon(Icons.person_rounded, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 4),
          Text('1 Adult · Economy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),

      Container(
        height: 44, color: Colors.white,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: airlines.length,
          itemBuilder: (_, i) {
            final active = airlines[i] == _filterAirline;
            return GestureDetector(
              onTap: () => setState(() => _filterAirline = airlines[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? AppColors.primary : AppColors.border),
                ),
                child: Text(airlines[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: active ? Colors.black87 : AppColors.textSecondary)),
              ),
            );
          },
        ),
      ),

      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: Row(children: [
          Text('${filtered.length} flights found',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          const Spacer(),
          Text('Sorted by $_sort', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ]),
      ),

      Expanded(child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filtered.length,
        itemBuilder: (_, i) => _FlightCard(
          flight: filtered[i],
          onBook: (f, pax, cls, payment, name, phone) {
            final pnr = 'FK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
            setState(() => _myBookings.insert(0, {
              'pnr': pnr, 'flight': f, 'passengers': pax,
              'class': cls, 'payment': payment, 'name': name, 'phone': phone,
              'status': 'Confirmed', 'total': f.price * pax,
            }));
            return pnr;
          },
        ),
      )),
    ]);
  }

  Widget _bookingsTab() {
    if (_myBookings.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('✈️', style: TextStyle(fontSize: 60)),
        SizedBox(height: 16),
        Text('No bookings yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        Text('Book a flight to see it here', style: TextStyle(color: AppColors.textSecondary)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myBookings.length,
      itemBuilder: (_, i) {
        final b = _myBookings[i];
        final f = b['flight'] as FlightModel;
        final cancelled = b['status'] == 'Cancelled';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cancelled ? Colors.grey.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(f.airlineLogo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${f.airline} · ${f.flightNumber}', style: const TextStyle(fontWeight: FontWeight.w800)),
                Text('PNR: ${b['pnr']}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cancelled ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(b['status'], style: TextStyle(
                    color: cancelled ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ]),
            const Divider(height: 16),

            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.departure, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text(f.fromCode, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ])),
              Column(children: [
                const Icon(Icons.flight_rounded, color: AppColors.primary, size: 18),
                Text(f.duration, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ]),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(f.arrival, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text(f.toCode, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ])),
            ]),
            const SizedBox(height: 10),

            Row(children: [
              Text('${b['passengers']} pax · ${b['class']} · ${b['payment']}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              Text('₹${b['total']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.accent)),
            ]),

            if (!cancelled) ...[
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => _showCancelDialog(i),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: const Text('Cancel Ticket', style: TextStyle(color: AppColors.error, fontSize: 12)),
                )),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(
                  onPressed: () => _showPNRStatus(b),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: const Text('PNR Status', style: TextStyle(fontSize: 12)),
                )),
              ]),
            ],
          ]),
        );
      },
    );
  }

  void _showCancelDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Ticket?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Cancellation charges may apply. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              setState(() => _myBookings[index]['status'] = 'Cancelled');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Ticket cancelled. Refund will be processed in 5-7 days.'),
                backgroundColor: AppColors.error));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPNRStatus(Map<String, dynamic> b) {
    final f = b['flight'] as FlightModel;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('PNR Status', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _pnrRow('PNR', b['pnr']),
              _pnrRow('Status', b['status']),
              _pnrRow('Flight', '${f.airline} ${f.flightNumber}'),
              _pnrRow('Route', '${f.fromCode} → ${f.toCode}'),
              _pnrRow('Departure', f.departure),
              _pnrRow('Arrival', f.arrival),
              _pnrRow('Passengers', '${b['passengers']}'),
              _pnrRow('Class', b['class']),
            ]),
          ),
        ]),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _pnrRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _FlightCard extends StatelessWidget {
  final FlightModel flight;
  final String Function(FlightModel, int, String, String, String, String) onBook;
  const _FlightCard({required this.flight, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBookingSheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(flight.airlineLogo,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)))),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(flight.airline, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                Text(flight.flightNumber, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
              const Spacer(),
              if (flight.isNonstop)
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Nonstop', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success))),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(flight.departure, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                Text(flight.fromCode, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                Text(flight.from, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
              ]),
              Expanded(child: Column(children: [
                Row(children: [
                  Expanded(child: Container(height: 1, color: AppColors.border)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(children: [
                      const Icon(Icons.flight_rounded, color: AppColors.primary, size: 20),
                      Text(flight.duration, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    ])),
                  Expanded(child: Container(height: 1, color: AppColors.border)),
                ]),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(flight.arrival, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                Text(flight.toCode, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                Text(flight.to, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
              ]),
            ]),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('₹${flight.price}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.accent)),
                const Text('per person', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ]),
              const Spacer(),
              if (flight.seatsLeft <= 8)
                Container(margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('Only ${flight.seatsLeft} left!',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.red))),
              ElevatedButton(
                onPressed: () => _showBookingSheet(context),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                child: const Text('Book', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showBookingSheet(BuildContext context) {
    int passengers = 1;
    String selectedClass = 'Economy';
    String payment = 'UPI';
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
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
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(flight.airlineLogo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(flight.airline, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                Text('${flight.flightNumber} · ${flight.fromCode} → ${flight.toCode}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
            const Divider(),

            Expanded(child: SingleChildScrollView(child: step == 0
              // Step 0: Flight + Class
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(flight.departure, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        Text(flight.fromCode, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                      Expanded(child: Column(children: [
                        const Icon(Icons.flight_rounded, color: AppColors.primary),
                        Text(flight.duration, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(flight.arrival, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        Text(flight.toCode, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                    ])),
                  const SizedBox(height: 16),
                  const Text('Class', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(children: ['Economy', 'Business', 'First'].map((c) => GestureDetector(
                    onTap: () => setS(() => selectedClass = c),
                    child: Container(margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedClass == c ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selectedClass == c ? AppColors.primary : AppColors.border)),
                      child: Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: selectedClass == c ? Colors.black87 : AppColors.textSecondary))),
                  )).toList()),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Text('Passengers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () { if (passengers > 1) setS(() => passengers--); }),
                    Text('$passengers', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        onPressed: () { if (passengers < 9) setS(() => passengers++); }),
                  ]),
                ])
              // Step 1: Passenger details
              : step == 1
              ? Column(children: [
                  TextField(controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Passenger Name', prefixIcon: Icon(Icons.person_rounded), border: OutlineInputBorder())),
                  const SizedBox(height: 14),
                  TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_rounded), border: OutlineInputBorder())),
                  const SizedBox(height: 20),
                  const Align(alignment: Alignment.centerLeft,
                    child: Text('Payment Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 10),
                  ...['UPI', 'Card', 'Net Banking'].map((p) => GestureDetector(
                    onTap: () => setS(() => payment = p),
                    child: Container(margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: payment == p ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: payment == p ? AppColors.primary : AppColors.border)),
                      child: Row(children: [
                        Text(p, style: TextStyle(fontWeight: FontWeight.w700,
                            color: payment == p ? AppColors.primary : Colors.black87)),
                        const Spacer(),
                        if (payment == p) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                      ])),
                  )),
                ])
              // Step 2: Confirm
              : Column(children: [
                  Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                    child: Column(children: [
                      _row('Flight', '${flight.airline} ${flight.flightNumber}'),
                      _row('Route', '${flight.fromCode} → ${flight.toCode}'),
                      _row('Departure', flight.departure),
                      _row('Class', selectedClass),
                      _row('Passengers', '$passengers'),
                      _row('Passenger', nameCtrl.text.isEmpty ? 'Guest' : nameCtrl.text),
                      _row('Payment', payment),
                      const Divider(height: 20),
                      _row('Total', '₹${flight.price * passengers}', bold: true),
                    ])),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final pnr = onBook(flight, passengers, selectedClass, payment, nameCtrl.text, phoneCtrl.text);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('✈️ ${flight.airline} booked! PNR: $pnr'),
                          backgroundColor: AppColors.success, duration: const Duration(seconds: 4)));
                      },
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: Text('Pay ₹${flight.price * passengers}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    )),
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                    )),
                ]),
            )),

            if (step < 2)
              SizedBox(width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => setS(() => step++),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(step == 0 ? 'Continue to Details' : 'Review Booking',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                )),
          ]),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      Text(value, style: TextStyle(fontSize: bold ? 16 : 12,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          color: bold ? AppColors.accent : Colors.black87)),
    ]),
  );
}