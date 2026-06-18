// lib/screens/orders/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../providers/movie_booking_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    context.read<OrderProvider>().loadOrders();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Past'),
            Tab(text: '🎬 Movies'),
          ],
        ),
      ),
      body: Consumer2<OrderProvider, MovieBookingProvider>(
        builder: (_, orderProv, movieProv, __) {
          if (orderProv.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          return TabBarView(
            controller: _tabs,
            children: [
              _OrderList(orders: orderProv.activeOrders, isActive: true),
              _OrderList(orders: orderProv.pastOrders, isActive: false),
              _MovieBookingList(bookings: movieProv.bookings),
            ],
          );
        },
      ),
    );
  }
}

// ─── Food Order List ───────────────────────────────────────────────────────
class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final bool isActive;
  const _OrderList({required this.orders, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🛍️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(isActive ? 'No active orders' : 'No past orders',
              style: Theme.of(context).textTheme.titleMedium),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _OrderCard(order: orders[i]),
    );
  }
}

// ─── Movie Booking List ────────────────────────────────────────────────────
class _MovieBookingList extends StatelessWidget {
  final List<MovieBookingModel> bookings;
  const _MovieBookingList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('🎬', style: TextStyle(fontSize: 56)),
          SizedBox(height: 12),
          Text('No movie bookings yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text('Book your first movie ticket!',
              style: TextStyle(color: AppColors.textSecondary)),
        ]),
      );
    }

    // Group by date
    final Map<String, List<MovieBookingModel>> grouped = {};
    for (final b in bookings) {
      grouped.putIfAbsent(b.date, () => []).add(b);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 4),
            child: Text(entry.key,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
          ),
          ...entry.value.map((b) => _MovieBookingCard(booking: b)),
          const SizedBox(height: 8),
        ]);
      }).toList(),
    );
  }
}

// ─── Movie Booking Card ────────────────────────────────────────────────────
class _MovieBookingCard extends StatelessWidget {
  final MovieBookingModel booking;
  const _MovieBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
      ),
      child: Column(children: [
        // ── Movie info ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(booking.movieImage,
                width: 60, height: 80, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60, height: 80, color: const Color(0xFF1a1a2e),
                  child: const Icon(Icons.movie, color: Colors.white, size: 28))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.movieTitle,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Row(children: [
                const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(child: Text('${booking.date}  ${booking.showtime}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              ]),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(child: Text(booking.theater,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ])),
            // Cancelled stamp
            if (booking.isCancelled)
              Transform.rotate(
                angle: -0.4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.error, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('CANCELLED',
                      style: TextStyle(color: AppColors.error, fontSize: 9,
                          fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
          ]),
        ),

        // ── Dashed divider ─────────────────────────────────────────
        Row(children: [
          Container(width: 16, height: 16,
              decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border))),
          Expanded(child: Container(height: 1, color: AppColors.border)),
          Container(width: 16, height: 16,
              decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border))),
        ]),

        // ── Seat & ticket info ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('${booking.seats.length}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
              const Text('Tickets', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ]),
            const SizedBox(width: 16),
            Container(width: 1, height: 40, color: AppColors.border),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.audi,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text('SEATS - ${booking.seats.join(', ')}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('₹${booking.totalAmount}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.accent)),
              Text(booking.isCancelled ? 'Refunded' : 'Paid',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: booking.isCancelled ? AppColors.error : AppColors.success)),
            ]),
          ]),
        ),

        // ── User details ────────────────────────────────────────────
        if (booking.userName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.person_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(booking.userName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  const Icon(Icons.phone_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(booking.userPhone,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
                if (booking.userEmail.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.email_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(booking.userEmail,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                ],
              ]),
            ),
          ),

        // ── Cancel button (only if not cancelled) ─────────────────
        if (!booking.isCancelled)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: GestureDetector(
              onTap: () => _showCancelDialog(context, booking),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: const Text('Cancel Booking',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
      ]),
    );
  }

  void _showCancelDialog(BuildContext context, MovieBookingModel booking) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Cancel ${booking.movieTitle} tickets?\nRefund will be processed in 3-5 days.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              context.read<MovieBookingProvider>().cancelBooking(booking.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

// ─── Food Order Card ───────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.delivered: return AppColors.success;
      case OrderStatus.cancelled: return AppColors.error;
      case OrderStatus.onTheWay:  return AppColors.info;
      default:                    return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(order.restaurantName, style: Theme.of(context).textTheme.titleMedium)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(order.statusLabel,
                  style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(order.items.map((i) => '${i.name} x${i.quantity}').join(', '),
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const Divider(height: 16),
          Row(children: [
            Text('₹${order.total.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium),
            Text(' • ${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            if (order.isActive)
              TextButton(
                onPressed: () => context.push('/tracking/${order.id}'),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Track Order'),
              ),
            if (!order.isActive)
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Reorder'),
              ),
          ]),
        ]),
      ),
    );
  }
}