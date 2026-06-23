// lib/screens/movies/movies_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/mock_data.dart';
import '../../providers/movie_booking_provider.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});
  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final movies = mockMovies();
  String _selected = 'All';
  final genres = ['All', 'Action', 'Drama', 'Comedy', 'Historical', 'Thriller', 'Sci-Fi'];

  @override
  Widget build(BuildContext context) {
    final filtered = _selected == 'All'
        ? movies
        : movies.where((m) => m.genre.contains(_selected)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Movies & Shows 🎬', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Column(children: [
        Container(
          height: 48, color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: genres.length,
            itemBuilder: (_, i) {
              final active = genres[i] == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = genres[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(genres[i], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                      color: active ? Colors.black87 : AppColors.textSecondary)),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.58,
              crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _MovieCard(movie: filtered[i]),
          ),
        ),
      ]),
    );
  }
}

Color _posterColor(String title) {
  final colors = [
    const Color(0xFF1a1a2e), const Color(0xFF16213e), const Color(0xFF0f3460),
    const Color(0xFF533483), const Color(0xFF2d6a4f), const Color(0xFF6d2b3d),
    const Color(0xFF1b4332), const Color(0xFF3d405b), const Color(0xFF2c3e50),
    const Color(0xFF4a1942), const Color(0xFF1a3a4a), const Color(0xFF2d3561),
  ];
  int idx = title.codeUnits.fold(0, (a, b) => a + b) % colors.length;
  return colors[idx];
}

Color _posterAccent(String genre) {
  if (genre.contains('Action')) return const Color(0xFFe63946);
  if (genre.contains('Drama')) return const Color(0xFFf4a261);
  if (genre.contains('Comedy')) return const Color(0xFF2ec4b6);
  if (genre.contains('Historical')) return const Color(0xFFe9c46a);
  if (genre.contains('Horror')) return const Color(0xFF9b2335);
  if (genre.contains('Sci-Fi')) return const Color(0xFF4cc9f0);
  if (genre.contains('Romance')) return const Color(0xFFff6b9d);
  if (genre.contains('Thriller')) return const Color(0xFFff6b35);
  if (genre.contains('War')) return const Color(0xFF8ecae6);
  if (genre.contains('Crime')) return const Color(0xFFe63946);
  return const Color(0xFFffd166);
}

const List<Map<String, dynamic>> _theaters = [
  {'name': 'PVR Phoenix Mall', 'location': 'Lower Parel', 'distance': '1.2 km'},
  {'name': 'INOX R-City Mall', 'location': 'Ghatkopar', 'distance': '3.4 km'},
  {'name': 'Cinepolis Viviana', 'location': 'Thane', 'distance': '5.1 km'},
  {'name': 'PVR Juhu', 'location': 'Juhu', 'distance': '2.8 km'},
  {'name': 'INOX Nariman Point', 'location': 'South Mumbai', 'distance': '6.0 km'},
];

enum SeatCategory { normal, executive, premium }

const _normalColor    = Color(0xFF00BCD4);
const _executiveColor = Color(0xFF7C4DFF);
const _premiumColor   = Color(0xFFFFC107);

const _premiumRows   = ['I', 'J', 'K'];
const _executiveRows = ['C', 'D', 'E', 'F', 'G', 'H'];

SeatCategory _rowCategory(String row) {
  if (_premiumRows.contains(row)) return SeatCategory.premium;
  if (_executiveRows.contains(row)) return SeatCategory.executive;
  return SeatCategory.normal;
}

Color _categoryColor(SeatCategory cat) {
  switch (cat) {
    case SeatCategory.premium:   return _premiumColor;
    case SeatCategory.executive: return _executiveColor;
    case SeatCategory.normal:    return _normalColor;
  }
}

int _categoryPrice(SeatCategory cat) {
  switch (cat) {
    case SeatCategory.premium:   return 300;
    case SeatCategory.executive: return 200;
    case SeatCategory.normal:    return 120;
  }
}

// ✅ NEW: deterministic per-show seat occupancy.
// Same movie + theater + showtime always produces the same layout
// (so it's not a single fixed mock list reused everywhere), while a
// different show genuinely looks different — closer to real seat maps.
const List<String> _allSeatRows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];

Set<String> _generateOccupiedSeats({
  required String movieTitle,
  required String theater,
  required String showtime,
  required int seatsPerRow,
}) {
  final key = '$movieTitle|$theater|$showtime';
  final seed = key.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0x7fffffff);
  final rnd = Random(seed);
  final occupied = <String>{};

  for (final row in _allSeatRows) {
    // each row independently 15%–55% occupied, varies per show via the seed
    final occupancy = 2 + rnd.nextInt(5); // 2..6 seats out of 12
    final nums = List.generate(seatsPerRow, (i) => i + 1)..shuffle(rnd);
    for (var i = 0; i < occupancy; i++) {
      occupied.add('$row${nums[i]}');
    }
  }
  return occupied;
}

class _SeatMap extends StatefulWidget {
  final String movieTitle;
  final String theater;
  final String showtime;
  final Function(List<String>, int) onSeatsChanged;
  const _SeatMap({
    required this.movieTitle,
    required this.theater,
    required this.showtime,
    required this.onSeatsChanged,
  });
  @override
  State<_SeatMap> createState() => _SeatMapState();
}

class _SeatMapState extends State<_SeatMap> {
  final Set<String> _selected = {};
  late Set<String> _booked;
  final int seatsPerRow = 12;

  @override
  void initState() {
    super.initState();
    _booked = _buildBookedSeats();
  }

  @override
  void didUpdateWidget(covariant _SeatMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Theater/showtime can change while this screen stays mounted
    // (e.g. user goes back a step) — regenerate occupancy for the new show.
    if (oldWidget.movieTitle != widget.movieTitle ||
        oldWidget.theater != widget.theater ||
        oldWidget.showtime != widget.showtime) {
      setState(() {
        _selected.clear();
        _booked = _buildBookedSeats();
      });
      widget.onSeatsChanged(const [], 0);
    }
  }

  Set<String> _buildBookedSeats() {
    final booked = _generateOccupiedSeats(
      movieTitle: widget.movieTitle,
      theater: widget.theater,
      showtime: widget.showtime,
      seatsPerRow: seatsPerRow,
    );

    // ✅ Lock seats this user has actually booked for this exact show,
    // so the same seats can never be selected/double-booked again.
    final provider = context.read<MovieBookingProvider>();
    for (final b in provider.activeBookings) {
      if (b.movieTitle == widget.movieTitle &&
          b.theater == widget.theater &&
          b.showtime == widget.showtime) {
        booked.addAll(b.seats);
      }
    }
    return booked;
  }

  int get _totalPrice {
    int total = 0;
    for (final seat in _selected) {
      total += _categoryPrice(_rowCategory(seat.substring(0, 1)));
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16), width: 400,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [
            Colors.transparent, Colors.grey.shade300, Colors.transparent])),
          child: const Text('SCREEN', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w700, letterSpacing: 4)),
        ),
        _sectionLabel('PREMIUM', 300, _premiumColor),
        const SizedBox(height: 6),
        for (final row in ['K', 'J', 'I']) _buildRow(row),
        const SizedBox(height: 20),
        _sectionLabel('EXECUTIVE', 200, _executiveColor),
        const SizedBox(height: 6),
        for (final row in ['H', 'G', 'F', 'E', 'D', 'C']) _buildRow(row),
        const SizedBox(height: 20),
        _sectionLabel('NORMAL', 120, _normalColor),
        const SizedBox(height: 6),
        for (final row in ['B', 'A']) _buildRow(row),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legend(_normalColor,    'Normal ₹120'),
          const SizedBox(width: 12),
          _legend(_executiveColor, 'Executive ₹200'),
          const SizedBox(width: 12),
          _legend(_premiumColor,   'Premium ₹300'),
          const SizedBox(width: 12),
          _legend(Colors.grey.shade300, 'Booked'),
        ]),
      ]),
    );
  }

  Widget _sectionLabel(String label, int price, Color color) => Text(
    '$label : ₹$price',
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color, letterSpacing: 1));

  Widget _buildRow(String row) {
    final color = _categoryColor(_rowCategory(row));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 22, child: Text(row, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color))),
        const SizedBox(width: 4),
        for (int num = seatsPerRow; num >= 1; num--) _buildSeat(row, num, color),
        const SizedBox(width: 4),
        SizedBox(width: 22, child: Text(row, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color))),
      ]),
    );
  }

  Widget _buildSeat(String row, int num, Color color) {
    final seat = '$row$num';
    final isBooked   = _booked.contains(seat);
    final isSelected = _selected.contains(seat);
    Color bgColor, borderColor, textColor;
    if (isBooked) {
      bgColor = Colors.grey.shade300; borderColor = Colors.grey.shade400; textColor = Colors.grey.shade500;
    } else if (isSelected) {
      bgColor = color; borderColor = color; textColor = Colors.white;
    } else {
      bgColor = Colors.white; borderColor = color; textColor = color;
    }
    return GestureDetector(
      onTap: isBooked ? null : () {
        setState(() { isSelected ? _selected.remove(seat) : _selected.add(seat); });
        widget.onSeatsChanged(_selected.toList(), _totalPrice);
      },
      child: Container(
        width: 28, height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 1.5)),
        child: Center(child: Text('$num',
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: textColor))),
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(children: [
    Container(width: 14, height: 14,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color == Colors.grey.shade300 ? Colors.grey.shade400 : color))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
  ]);
}

class _MovieCard extends StatelessWidget {
  final MovieModel movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    final accentColor = _posterAccent(movie.genre);
    final bgColor = _posterColor(movie.title);
    return GestureDetector(
      onTap: () => _show(context),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(height: 210, width: double.infinity,
              child: Stack(fit: StackFit.expand, children: [
                Image.network(movie.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [bgColor, bgColor.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight)))),
                Container(decoration: BoxDecoration(gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                Positioned(top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.star_rounded, size: 11, color: Color(0xFFFFD700)),
                      Text(' ${movie.rating}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ]))),
                Positioned(bottom: 0, left: 0, right: 0,
                  child: Padding(padding: const EdgeInsets.all(10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Row(children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(4)),
                          child: Text(movie.language, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))),
                        const SizedBox(width: 6),
                        Text(movie.duration, style: const TextStyle(color: Colors.white70, fontSize: 9)),
                      ]),
                    ]))),
              ])),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(movie.genre, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                Text('₹${movie.price}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: accentColor)),
                const Text(' /seat', style: TextStyle(fontSize: 9, color: AppColors.textHint)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFFFB300)]), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Book', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)))),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  void _show(BuildContext context) => showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => _BookingFlow(movie: movie),
  );
}

class _BookingFlow extends StatefulWidget {
  final MovieModel movie;
  const _BookingFlow({required this.movie});
  @override
  State<_BookingFlow> createState() => _BookingFlowState();
}

class _BookingFlowState extends State<_BookingFlow> {
  int _step = 0;
  String? _selectedTheater;
  String? _selectedTime;
  List<String> _selectedSeats = [];
  int _seatTotal = 0;
  String _selectedFormat  = '2D';
  String _selectedPayment = 'UPI';

  // ✅ User details controllers
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _detailsFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _posterAccent(widget.movie.genre);
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(8),
              child: Image.network(widget.movie.imageUrl, width: 45, height: 60, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 45, height: 60,
                  color: _posterColor(widget.movie.title), child: const Icon(Icons.movie, color: Colors.white, size: 24)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.movie.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              Text(widget.movie.genre, style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600)),
              Text('${widget.movie.language} · ${widget.movie.duration}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ])),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: List.generate(5, (i) {
            final labels = ['Theater', 'Showtime', 'Seats', 'Details', 'Confirm'];
            final done = i < _step; final active = i == _step;
            return Expanded(child: Row(children: [
              Expanded(child: Column(children: [
                Container(width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: done ? AppColors.success : active ? AppColors.primary : Colors.grey.shade200,
                    shape: BoxShape.circle),
                  child: Center(child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text('${i+1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                        color: active ? Colors.white : Colors.grey)))),
                const SizedBox(height: 3),
                Text(labels[i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                    color: active ? AppColors.primary : Colors.grey)),
              ])),
              if (i < 3) Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 16),
                color: done ? AppColors.success : Colors.grey.shade200)),
            ]));
          })),
        ),

        const Divider(height: 1),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _step == 0 ? _theaterStep()
              : _step == 1 ? _showtimeStep()
              : _step == 2 ? _seatsStep()
              : _step == 3 ? _detailsStep()
              : _confirmStep(),
        )),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_step == 0 && _selectedTheater == null) return;
                if (_step == 1 && _selectedTime == null) return;
                if (_step == 2 && _selectedSeats.isEmpty) return;

                // Validate user details before leaving step 3 (Details)
                if (_step == 3) {
                  final name  = _nameCtrl.text.trim();
                  final phone = _phoneCtrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please enter your name'),
                      backgroundColor: Colors.redAccent,
                    ));
                    return;
                  }
                  if (phone.length < 10) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Enter valid 10 digit mobile number'),
                      backgroundColor: Colors.redAccent,
                    ));
                    return;
                  }
                }

                // FIX 1: was `_step < 3` which finalized the booking right after
                // the Details step and never showed the Confirm/payment step.
                if (_step < 4) {
                  setState(() => _step++);
                } else {
                  final convenience = (_seatTotal * 0.1).round();
                  final grand = _seatTotal + convenience;

                  context.read<MovieBookingProvider>().addBooking(
                    movieTitle:  widget.movie.title,
                    movieImage:  widget.movie.imageUrl,
                    theater:     _selectedTheater ?? '',
                    showtime:    _selectedTime ?? '',
                    seats:       _selectedSeats,
                    totalAmount: grand,
                    userName:    _nameCtrl.text.trim(),
                    userPhone:   _phoneCtrl.text.trim(),
                    userEmail:   _emailCtrl.text.trim(),
                  );

                  // FIX 2: capture messenger + values BEFORE popping the sheet.
                  // Calling ScaffoldMessenger.of(context) after Navigator.pop(context)
                  // throws because `context` is no longer in the widget tree, so the
                  // snackbar (and the apparent "confirmation") silently never showed.
                  final messenger = ScaffoldMessenger.of(context);
                  final movieTitle = widget.movie.title;
                  final seatsLabel = _selectedSeats.join(", ");

                  Navigator.pop(context);

                  messenger.showSnackBar(SnackBar(
                    content: Text('🎬 $movieTitle booked! Seats: $seatsLabel'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 4),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(
                    _step == 0 ? 'Continue' :
                    _step == 1 ? 'Continue' :
                    _step == 2 ? (_selectedSeats.isEmpty ? 'Select Seats First'
                        : 'Proceed · ₹$_seatTotal (${_selectedSeats.length} seats)') :
                    _step == 3 ? 'Confirm Booking' :
                    'Pay ₹${_seatTotal + (_seatTotal * 0.1).round()}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ]),
    );
  }

  bool _canProceed() {
    if (_step == 0) return _selectedTheater != null;
    if (_step == 1) return _selectedTime != null;
    if (_step == 2) return _selectedSeats.isNotEmpty;
    if (_step == 3) return true; // validate on tap
    return true;
  }

  void _nextStep() => setState(() => _step++);

  Widget _theaterStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Select Theater', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('Cinemas near you', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 14),
      ..._theaters.map((t) {
        final selected = _selectedTheater == t['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedTheater = t['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
            ),
            child: Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.background,
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.movie_outlined, color: selected ? AppColors.primary : AppColors.textSecondary, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t['name']!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: selected ? AppColors.primary : Colors.black87)),
                const SizedBox(height: 2),
                Text(t['location']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(t['distance']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: selected ? AppColors.primary : AppColors.textSecondary)),
                if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
              ]),
            ]),
          ),
        );
      }),
    ]);
  }

  Widget _showtimeStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_selectedTheater ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('Select showtime', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 16),
      const Text('TODAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppColors.textSecondary, letterSpacing: 1)),
      const SizedBox(height: 10),
      Wrap(spacing: 10, runSpacing: 10,
        children: widget.movie.showtimes.map((t) {
          final selected = _selectedTime == t;
          return GestureDetector(
            onTap: () => setState(() => _selectedTime = t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selected ? AppColors.primary : AppColors.border),
              ),
              child: Column(children: [
                Text(t, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : Colors.black87)),
                Text(selected ? 'Selected' : 'Available',
                    style: TextStyle(fontSize: 9, color: selected ? Colors.white70 : AppColors.success)),
              ]),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      const Text('FORMAT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppColors.textSecondary, letterSpacing: 1)),
      const SizedBox(height: 10),
      Row(children: ['2D', '3D', 'IMAX'].map((f) {
        final selected = _selectedFormat == f;
        return GestureDetector(
          onTap: () => setState(() => _selectedFormat = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
            ),
            child: Text(f, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.textSecondary)),
          ),
        );
      }).toList()),
    ]);
  }

  Widget _seatsStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Select Seats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          Text('Tap to select your seats', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        if (_selectedSeats.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('${_selectedSeats.length} seat${_selectedSeats.length > 1 ? 's' : ''} · ₹$_seatTotal',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
      ]),
      const SizedBox(height: 12),
      // ✅ Pass movie + theater + showtime so occupancy reflects this exact
      // show instead of one fixed mock layout for every booking.
      _SeatMap(
        movieTitle: widget.movie.title,
        theater: _selectedTheater ?? '',
        showtime: _selectedTime ?? '',
        onSeatsChanged: (seats, total) => setState(() { _selectedSeats = seats; _seatTotal = total; }),
      ),
      if (_selectedSeats.isNotEmpty) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.event_seat_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Seats: ${_selectedSeats.join(', ')}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
            Text('₹$_seatTotal', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.accent)),
          ]),
        ),
      ],
    ]);
  }

  // ── Step 3: User Details ──────────────────────────────────────
  Widget _detailsStep() {
    return Form(
      key: _detailsFormKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Your Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Required for booking confirmation & ticket',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        // Name
        _detailField(
          controller: _nameCtrl,
          label: 'Full Name',
          hint: 'E.g. Rahul Sharma',
          icon: Icons.person_rounded,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Name required';
            if (v.trim().length < 2) return 'At least 2 characters';
            return null;
          },
          onChanged: (_) {},
        ),
        const SizedBox(height: 14),

        // Phone
        _detailField(
          controller: _phoneCtrl,
          label: 'Mobile Number',
          hint: '10 digit number',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Phone required';
            if (v.length < 10) return 'Enter 10 digits';
            return null;
          },
          onChanged: (_) {},
        ),
        const SizedBox(height: 14),

        // Email (optional)
        _detailField(
          controller: _emailCtrl,
          label: 'Email (optional)',
          hint: 'For e-ticket delivery',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) {},
        ),
        const SizedBox(height: 20),

        // Booking mini summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(children: [
            _miniRow('🎬', 'Movie', widget.movie.title),
            _miniRow('🏟️', 'Theater', _selectedTheater ?? ''),
            _miniRow('🕐', 'Showtime', _selectedTime ?? ''),
            _miniRow('💺', 'Seats', '${_selectedSeats.join(', ')} (${_selectedSeats.length})'),
            _miniRow('🎞️', 'Format', _selectedFormat),
            const Divider(height: 16),
            _miniRow('💰', 'Total', '₹${_seatTotal + (_seatTotal * 0.1).round()}'),
          ]),
        ),
      ]),
    );
  }

  Widget _detailField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
    required Function(String) onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: AppColors.textHint),
          counterText: '',
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    ]);
  }

  Widget _miniRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        Flexible(child: Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _confirmStep() {
    final convenience = (_seatTotal * 0.1).round();
    final grand = _seatTotal + convenience;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Booking Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          _summaryRow('Movie',    widget.movie.title),
          _summaryRow('Theater', _selectedTheater ?? ''),
          _summaryRow('Showtime', _selectedTime ?? ''),
          _summaryRow('Seats',   _selectedSeats.join(', ')),
          _summaryRow('Format',  _selectedFormat),
          const Divider(height: 20),
          _summaryRow('Ticket (${_selectedSeats.length}x)', '₹$_seatTotal'),
          _summaryRow('Convenience Fee', '₹$convenience'),
          const Divider(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            Text('₹$grand', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.accent)),
          ]),
        ]),
      ),
      const SizedBox(height: 20),
      const Text('Pay With', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Row(children: ['UPI', 'Card', 'Wallet'].map((p) {
        final selected = _selectedPayment == p;
        return GestureDetector(
          onTap: () => setState(() => _selectedPayment = p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
            ),
            child: Text(p, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.textSecondary)),
          ),
        );
      }).toList()),
      const SizedBox(height: 24),

      // Pay button (bottom button handles payment — this is just visual summary)
    ]);
  }

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Flexible(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]),
  );
}