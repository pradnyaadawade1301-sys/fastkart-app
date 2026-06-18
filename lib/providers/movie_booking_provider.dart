// lib/providers/movie_booking_provider.dart
import 'package:flutter/foundation.dart';

class MovieBookingModel {
  final String id;
  final String movieTitle;
  final String movieImage;
  final String theater;
  final String audi;
  final String showtime;
  final String date;
  final List<String> seats;
  final int totalAmount;
  final bool isCancelled;
  final DateTime bookedAt;
  // ✅ User details
  final String userName;
  final String userPhone;
  final String userEmail;

  MovieBookingModel({
    required this.id,
    required this.movieTitle,
    required this.movieImage,
    required this.theater,
    required this.audi,
    required this.showtime,
    required this.date,
    required this.seats,
    required this.totalAmount,
    this.isCancelled = false,
    required this.bookedAt,
    this.userName  = '',
    this.userPhone = '',
    this.userEmail = '',
  });

  MovieBookingModel copyWith({bool? isCancelled}) => MovieBookingModel(
    id: id, movieTitle: movieTitle, movieImage: movieImage,
    theater: theater, audi: audi, showtime: showtime, date: date,
    seats: seats, totalAmount: totalAmount,
    isCancelled: isCancelled ?? this.isCancelled,
    bookedAt: bookedAt, userName: userName,
    userPhone: userPhone, userEmail: userEmail,
  );
}

class MovieBookingProvider extends ChangeNotifier {
  final List<MovieBookingModel> _bookings = [];

  List<MovieBookingModel> get bookings => List.unmodifiable(_bookings);
  List<MovieBookingModel> get activeBookings    => _bookings.where((b) => !b.isCancelled).toList();
  List<MovieBookingModel> get cancelledBookings => _bookings.where((b) => b.isCancelled).toList();

  void addBooking({
    required String movieTitle,
    required String movieImage,
    required String theater,
    required String showtime,
    required List<String> seats,
    required int totalAmount,
    String userName  = '',
    String userPhone = '',
    String userEmail = '',
  }) {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final date   = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    _bookings.insert(0, MovieBookingModel(
      id:          'MB${now.millisecondsSinceEpoch}',
      movieTitle:  movieTitle,
      movieImage:  movieImage,
      theater:     theater,
      audi:        'AUDI 0${(_bookings.length % 5) + 1}',
      showtime:    showtime,
      date:        date,
      seats:       List.from(seats),
      totalAmount: totalAmount,
      bookedAt:    now,
      userName:    userName,
      userPhone:   userPhone,
      userEmail:   userEmail,
    ));
    notifyListeners();
  }

  void cancelBooking(String id) {
    final i = _bookings.indexWhere((b) => b.id == id);
    if (i >= 0) {
      _bookings[i] = _bookings[i].copyWith(isCancelled: true);
      notifyListeners();
    }
  }
}