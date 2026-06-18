// lib/screens/favourite/favourite_screen.dart
import 'package:flutter/material.dart';
import '../../models/history_item.dart';
import '../../widgets/category_history_tab.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    _TabInfo(
      label: 'Food',
      icon: Icons.fastfood_outlined,
      category: HistoryCategory.food,
      emptyIcon: Icons.fastfood_outlined,
      emptyMessage: 'No food orders yet',
      emptySubtitle: 'Your food order history will appear here',
      emptyButton: null,
    ),
    _TabInfo(
      label: 'Movies',
      icon: Icons.movie_outlined,
      category: HistoryCategory.movies,
      emptyIcon: Icons.movie_outlined,
      emptyMessage: 'No movie bookings yet',
      emptySubtitle: 'Tickets you book will show up here',
      emptyButton: null,
    ),
    _TabInfo(
      label: 'Hotels',
      icon: Icons.hotel_outlined,
      category: HistoryCategory.hotels,
      emptyIcon: Icons.hotel_outlined,
      emptyMessage: 'No hotel bookings yet',
      emptySubtitle: 'Your hotel stays will appear here',
      emptyButton: null,
    ),
    _TabInfo(
      label: 'Leisure',
      icon: Icons.local_activity_outlined,
      category: HistoryCategory.leisure,
      emptyIcon: Icons.local_activity_outlined,
      emptyMessage: 'No leisure bookings yet',
      emptySubtitle: 'Activities and events you book will show here',
      emptyButton: null,
    ),
    _TabInfo(
      label: 'Ride',
      icon: Icons.directions_car_outlined,
      category: HistoryCategory.ride,
      emptyIcon: Icons.directions_car_outlined,
      emptyMessage: 'No rides yet',
      emptySubtitle: 'Your cab ride history will appear here',
      emptyButton: null,
    ),
    _TabInfo(
      label: 'Bike',
      icon: Icons.two_wheeler_outlined,
      category: HistoryCategory.bike,
      emptyIcon: Icons.two_wheeler_outlined,
      emptyMessage: 'No bike rides yet',
      emptySubtitle: 'Your bike ride history will appear here',
      emptyButton: null,
    ),
    _TabInfo(
      label: 'Travel',
      icon: Icons.flight_outlined,
      category: HistoryCategory.travel,
      emptyIcon: Icons.flight_outlined,
      emptyMessage: 'No travel bookings yet',
      emptySubtitle: 'Flights and trips you book will show here',
      emptyButton: null,
    ),
    _TabInfo(
      label: 'Grocery',
      icon: Icons.shopping_cart_outlined,
      category: HistoryCategory.grocery,
      emptyIcon: Icons.shopping_cart_outlined,
      emptyMessage: 'No grocery orders yet',
      emptySubtitle: 'Your grocery delivery history will show here',
      emptyButton: null,
    ),
    _TabInfo(
      label: 'More',
      icon: Icons.more_horiz,
      category: HistoryCategory.more,
      emptyIcon: Icons.receipt_long_outlined,
      emptyMessage: 'No other transactions yet',
      emptySubtitle: 'Bill payments, recharges and more will show here',
      emptyButton: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Saved',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: _tabs
              .map(
                (t) => Tab(
                  icon: Icon(t.icon, size: 20),
                  text: t.label,
                  height: 56,
                ),
              )
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs
            .map(
              (t) => CategoryHistoryTab(
                category: t.category,
                emptyIcon: t.emptyIcon,
                emptyMessage: t.emptyMessage,
                emptySubtitle: t.emptySubtitle,
                emptyButtonLabel: t.emptyButton,
                onEmptyAction: null,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TabInfo {
  final String label;
  final IconData icon;
  final HistoryCategory category;
  final IconData emptyIcon;
  final String emptyMessage;
  final String emptySubtitle;
  final String? emptyButton;

  const _TabInfo({
    required this.label,
    required this.icon,
    required this.category,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.emptySubtitle,
    required this.emptyButton,
  });
}