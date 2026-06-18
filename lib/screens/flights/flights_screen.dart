// lib/screens/flights/flights_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../services/history_service.dart';

class FlightModel {
  final String id, airline, airlineLogo, flightNumber;
  final String from, fromCode, to, toCode;
  final String departure, arrival, duration;
  final double price;
  final String cabinClass;
  final int stops;

  const FlightModel({
    required this.id,
    required this.airline,
    required this.airlineLogo,
    required this.flightNumber,
    required this.from,
    required this.fromCode,
    required this.to,
    required this.toCode,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.price,
    required this.cabinClass,
    required this.stops,
  });
}

// ── Passenger detail model ───────────────────────────────────────────────────
class PassengerDetail {
  String name;
  String email;
  String phone;
  PassengerDetail({this.name = '', this.email = '', this.phone = ''});
}

final _mockFlights = [
  const FlightModel(
    id: 'f1',
    airline: 'IndiGo',
    airlineLogo: '6E',
    flightNumber: '6E-204',
    from: 'Mumbai',
    fromCode: 'BOM',
    to: 'Delhi',
    toCode: 'DEL',
    departure: '06:00',
    arrival: '08:15',
    duration: '2h 15m',
    price: 3499,
    cabinClass: 'Economy',
    stops: 0,
  ),
  const FlightModel(
    id: 'f2',
    airline: 'Air India',
    airlineLogo: 'AI',
    flightNumber: 'AI-865',
    from: 'Mumbai',
    fromCode: 'BOM',
    to: 'Delhi',
    toCode: 'DEL',
    departure: '09:30',
    arrival: '11:50',
    duration: '2h 20m',
    price: 4799,
    cabinClass: 'Economy',
    stops: 0,
  ),
  const FlightModel(
    id: 'f3',
    airline: 'Vistara',
    airlineLogo: 'UK',
    flightNumber: 'UK-955',
    from: 'Mumbai',
    fromCode: 'BOM',
    to: 'Delhi',
    toCode: 'DEL',
    departure: '13:00',
    arrival: '15:20',
    duration: '2h 20m',
    price: 6299,
    cabinClass: 'Business',
    stops: 0,
  ),
  const FlightModel(
    id: 'f4',
    airline: 'SpiceJet',
    airlineLogo: 'SG',
    flightNumber: 'SG-114',
    from: 'Mumbai',
    fromCode: 'BOM',
    to: 'Delhi',
    toCode: 'DEL',
    departure: '16:45',
    arrival: '20:30',
    duration: '3h 45m',
    price: 2899,
    cabinClass: 'Economy',
    stops: 1,
  ),
  const FlightModel(
    id: 'f5',
    airline: 'Akasa Air',
    airlineLogo: 'QP',
    flightNumber: 'QP-1319',
    from: 'Mumbai',
    fromCode: 'BOM',
    to: 'Delhi',
    toCode: 'DEL',
    departure: '19:10',
    arrival: '21:25',
    duration: '2h 15m',
    price: 3199,
    cabinClass: 'Economy',
    stops: 0,
  ),
];

class FlightsScreen extends StatefulWidget {
  const FlightsScreen({super.key});

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> {
  FlightModel? _selected;
  int _passengers = 1;
  String _cabinClass = 'Economy';
  bool _isBooking = false;

  double get _totalPrice => (_selected?.price ?? 0) * _passengers;

  // ── Booking confirmation ─────────────────────────────────────────────────
  Future<void> _confirmBooking(List<PassengerDetail> details) async {
    if (_selected == null) return;
    setState(() => _isBooking = true);

    final pnr =
        'PNR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    await HistoryService.instance.saveItem(
      HistoryService.makeTravel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        route: '${_selected!.fromCode} → ${_selected!.toCode}',
        airline: _selected!.airline,
        flightNo: _selected!.flightNumber,
        classType: _cabinClass,
        passengers: _passengers,
        pnr: pnr,
        amount: _totalPrice,
        travelDate: DateTime.now().add(const Duration(days: 7)),
      ),
    );

    setState(() => _isBooking = false);
    if (!mounted) return;
    _showBookingSuccess(pnr, details);
  }

  // ── Success dialog ───────────────────────────────────────────────────────
  void _showBookingSuccess(String pnr, List<PassengerDetail> details) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.flight_takeoff_rounded, color: AppColors.success),
            SizedBox(width: 8),
            Text('Flight Booked!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_selected!.airline} ${_selected!.flightNumber}'),
            Text(
                '${_selected!.fromCode} → ${_selected!.toCode}  |  $_cabinClass'),
            Text('Passengers: $_passengers'),
            const SizedBox(height: 4),
            // Show first passenger name
            Text('Lead Passenger: ${details.first.name}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('PNR: $pnr',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: AppColors.primary)),
            Text('Total: ₹${_totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // ── Booking bottom sheet ────────────────────────────────────────────────
  void _showBookingSheet() {
    if (_selected == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(
        flight: _selected!,
        passengers: _passengers,
        cabinClass: _cabinClass,
        totalPrice: _totalPrice,
        isBooking: _isBooking,
        onConfirm: (details) {
          Navigator.pop(context);
          _confirmBooking(details);
        },
      ),
    );
  }

  // ── UI helpers ──────────────────────────────────────────────────────────
  Widget _bookingRow(String label, String value, {bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            Text(value,
                style: TextStyle(
                    fontSize: bold ? 16 : 13,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                    color:
                        bold ? AppColors.primary : AppColors.textPrimary)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Flights'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Filter bar ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        DropdownButton<int>(
                          value: _passengers,
                          underline: const SizedBox(),
                          isDense: true,
                          items: List.generate(
                            6,
                            (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('${i + 1} Adult')),
                          ),
                          onChanged: (v) =>
                              setState(() => _passengers = v!),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                            Icons.airline_seat_recline_normal_rounded,
                            size: 18,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        DropdownButton<String>(
                          value: _cabinClass,
                          underline: const SizedBox(),
                          isDense: true,
                          items: ['Economy', 'Business', 'First']
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _cabinClass = v!),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Flight list ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mockFlights.length,
              itemBuilder: (_, i) {
                final flight = _mockFlights[i];
                final isSelected = _selected?.id == flight.id;
                return GestureDetector(
                  onTap: () => setState(() => _selected = flight),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(flight.airlineLogo,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: AppColors.primary)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(flight.airline,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14)),
                                  Text(flight.flightNumber,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${flight.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17,
                                      color: AppColors.accent),
                                ),
                                const Text('/person',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(flight.departure,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900)),
                                Text(flight.fromCode,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(flight.duration,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Container(
                                              height: 1,
                                              color: AppColors.divider)),
                                      const Icon(Icons.flight_rounded,
                                          size: 16,
                                          color: AppColors.primary),
                                      Expanded(
                                          child: Container(
                                              height: 1,
                                              color: AppColors.divider)),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    flight.stops == 0
                                        ? 'Non-stop'
                                        : '${flight.stops} stop',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: flight.stops == 0
                                          ? AppColors.success
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(flight.arrival,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900)),
                                Text(flight.toCode,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Book button ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.white,
            child: Column(
              children: [
                if (_selected != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$_passengers passenger${_passengers > 1 ? 's' : ''} · $_cabinClass',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                        Text(
                          'Total: ₹${_totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _selected != null ? _showBookingSheet : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _selected == null
                          ? 'Select a Flight'
                          : 'Book Flight — ₹${_totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _BookingSheet — 2-step: Passenger Details → Review & Confirm
// ═══════════════════════════════════════════════════════════════════════════
class _BookingSheet extends StatefulWidget {
  final FlightModel flight;
  final int passengers;
  final String cabinClass;
  final double totalPrice;
  final bool isBooking;
  final void Function(List<PassengerDetail>) onConfirm;

  const _BookingSheet({
    required this.flight,
    required this.passengers,
    required this.cabinClass,
    required this.totalPrice,
    required this.isBooking,
    required this.onConfirm,
  });

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  // 0 = passenger details, 1 = review
  int _step = 0;

  late final List<PassengerDetail> _details;
  late final List<GlobalKey<FormState>> _formKeys;

  @override
  void initState() {
    super.initState();
    _details = List.generate(
        widget.passengers, (_) => PassengerDetail());
    _formKeys = List.generate(
        widget.passengers, (_) => GlobalKey<FormState>());
  }

  bool _validateAll() {
    bool valid = true;
    for (final key in _formKeys) {
      if (!(key.currentState?.validate() ?? false)) valid = false;
    }
    return valid;
  }

  void _nextStep() {
    if (_validateAll()) {
      for (final key in _formKeys) {
        key.currentState?.save();
      }
      setState(() => _step = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lift sheet above keyboard
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Step indicator row
            _StepIndicator(currentStep: _step),

            // Body
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0.05, 0), end: Offset.zero)
                        .animate(anim),
                    child: child,
                  )),
              child: _step == 0
                  ? _PassengerDetailsStep(
                      key: const ValueKey(0),
                      passengers: widget.passengers,
                      details: _details,
                      formKeys: _formKeys,
                      onNext: _nextStep,
                    )
                  : _ReviewStep(
                      key: const ValueKey(1),
                      flight: widget.flight,
                      cabinClass: widget.cabinClass,
                      passengers: widget.passengers,
                      totalPrice: widget.totalPrice,
                      details: _details,
                      isBooking: widget.isBooking,
                      onBack: () => setState(() => _step = 0),
                      onConfirm: () => widget.onConfirm(_details),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step indicator ──────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = ['Passenger Details', 'Review & Pay'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: currentStep > i ~/ 2
                    ? AppColors.primary
                    : AppColors.divider,
              ),
            );
          }
          final idx = i ~/ 2;
          final isActive = idx == currentStep;
          final isDone = idx < currentStep;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive || isDone
                      ? AppColors.primary
                      : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive || isDone
                        ? AppColors.primary
                        : AppColors.divider,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '${idx + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[idx],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Step 1: Passenger details ───────────────────────────────────────────────
class _PassengerDetailsStep extends StatelessWidget {
  final int passengers;
  final List<PassengerDetail> details;
  final List<GlobalKey<FormState>> formKeys;
  final VoidCallback onNext;

  const _PassengerDetailsStep({
    super.key,
    required this.passengers,
    required this.details,
    required this.formKeys,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                children: List.generate(passengers, (i) {
                  return _PassengerForm(
                    index: i,
                    detail: details[i],
                    formKey: formKeys[i],
                  );
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Continue to Review',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual passenger form ───────────────────────────────────────────────
class _PassengerForm extends StatelessWidget {
  final int index;
  final PassengerDetail detail;
  final GlobalKey<FormState> formKey;

  const _PassengerForm({
    required this.index,
    required this.detail,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Passenger ${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (index == 0) ...[
                  const SizedBox(width: 8),
                  const Text('(Lead)',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),

          // Full Name
          _buildField(
            label: 'Full Name',
            hint: 'As on government ID',
            icon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name required';
              if (v.trim().length < 3) {
                return 'Enter full name (min 3 chars)';
              }
              return null;
            },
            onSaved: (v) => detail.name = v!.trim(),
          ),
          const SizedBox(height: 12),

          // Email
          _buildField(
            label: 'Email Address',
            hint: 'e-ticket will be sent here',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email required';
              final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!re.hasMatch(v.trim())) return 'Enter valid email';
              return null;
            },
            onSaved: (v) => detail.email = v!.trim(),
          ),
          const SizedBox(height: 12),

          // Phone
          _buildField(
            label: 'Mobile Number',
            hint: '10-digit mobile number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Mobile number required';
              }
              if (v.trim().length != 10) {
                return 'Enter valid 10-digit number';
              }
              return null;
            },
            onSaved: (v) => detail.phone = v!.trim(),
          ),

          if (index < /* will be passed in */ 99)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Divider(),
            ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }
}

// ── Step 2: Review & Pay ────────────────────────────────────────────────────
class _ReviewStep extends StatefulWidget {
  final FlightModel flight;
  final String cabinClass;
  final int passengers;
  final double totalPrice;
  final List<PassengerDetail> details;
  final bool isBooking;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  const _ReviewStep({
    super.key,
    required this.flight,
    required this.cabinClass,
    required this.passengers,
    required this.totalPrice,
    required this.details,
    required this.isBooking,
    required this.onBack,
    required this.onConfirm,
  });

  @override
  State<_ReviewStep> createState() => _ReviewStepState();
}

class _ReviewStepState extends State<_ReviewStep> {
  String _selectedPayment = 'upi';

  static const _paymentOptions = [
    {'id': 'upi',  'label': 'UPI',          'sub': 'GPay, PhonePe, Paytm', 'icon': Icons.account_balance_wallet_rounded},
    {'id': 'card', 'label': 'Credit / Debit Card', 'sub': 'Visa, Mastercard, RuPay', 'icon': Icons.credit_card_rounded},
    {'id': 'nb',   'label': 'Net Banking',  'sub': 'All major banks supported', 'icon': Icons.account_balance_rounded},
    {'id': 'emi',  'label': 'EMI',          'sub': 'No-cost EMI available', 'icon': Icons.calendar_month_rounded},
  ];

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            Text(value,
                style: TextStyle(
                    fontSize: bold ? 16 : 13,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                    color: bold ? AppColors.primary : AppColors.textPrimary)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Flight summary ──
                  const Text('Flight Summary',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  _row('Flight', '${widget.flight.airline} ${widget.flight.flightNumber}'),
                  _row('Route', '${widget.flight.fromCode} → ${widget.flight.toCode}'),
                  _row('Time', '${widget.flight.departure} – ${widget.flight.arrival}'),
                  _row('Class', widget.cabinClass),
                  _row('Passengers', '${widget.passengers} adult'),

                  const Divider(height: 24),

                  // ── Passengers ──
                  const Text('Passengers',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  ...List.generate(widget.details.length, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(widget.details[i].name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(widget.details[i].email,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                      ]),
                    ]),
                  )),

                  const Divider(height: 16),
                  _row('Total Amount', '₹${widget.totalPrice.toStringAsFixed(0)}', bold: true),

                  const SizedBox(height: 20),

                  // ── Payment Methods ──
                  const Text('Payment Method',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 10),

                  ..._paymentOptions.map((opt) {
                    final isSelected = _selectedPayment == opt['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPayment = opt['id'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.06)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              opt['icon'] as IconData,
                              size: 20,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(opt['label'] as String,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary)),
                                Text(opt['sub'] as String,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.divider,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 12, color: Colors.white)
                                : null,
                          ),
                        ]),
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // ── Action buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Row(children: [
              OutlinedButton(
                onPressed: widget.onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: widget.isBooking ? null : widget.onConfirm,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: widget.isBooking
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Confirm & Pay',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}