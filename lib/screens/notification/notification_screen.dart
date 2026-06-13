// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

class _NotifItem {
  final String id, title, body, time, type;
  bool isRead;
  _NotifItem({required this.id, required this.title, required this.body,
      required this.time, required this.type, this.isRead = false});
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  final List<_NotifItem> _all = [
    _NotifItem(id:'n1', title:'Order Delivered! 🎉', body:'Your order from Punjabi Tadka has been delivered. Rate your experience!', time:'2 min ago', type:'order'),
    _NotifItem(id:'n2', title:'Driver is nearby 🛵', body:'Suresh Kumar is 0.5 km away. Get ready to receive your order.', time:'18 min ago', type:'order'),
    _NotifItem(id:'n3', title:'50% OFF on Groceries 🛒', body:'Use code FRESH50 on your next grocery order. Valid till midnight!', time:'1 hr ago', type:'offer', isRead: true),
    _NotifItem(id:'n4', title:'Order Confirmed ✅', body:'Your order #ORD004 from South Spice Kitchen is confirmed.', time:'2 hr ago', type:'order', isRead: true),
    _NotifItem(id:'n5', title:'FastKart Plus 👑', body:'Unlock free delivery on every order. Subscribe for just ₹99/month!', time:'5 hr ago', type:'promo'),
    _NotifItem(id:'n6', title:'Ride Completed 🚕', body:'Your ride to Bandra West is complete. Total fare: ₹127. Rate your driver!', time:'Yesterday', type:'ride', isRead: true),
    _NotifItem(id:'n7', title:'Movie Tickets Booked 🎬', body:'2 tickets for Pushpa 2 at PVR Juhu confirmed. Show: 8:00 PM tonight.', time:'Yesterday', type:'booking', isRead: true),
    _NotifItem(id:'n8', title:'Wallet Cashback 💰', body:'₹50 cashback added to your FastKart wallet! Check your balance.', time:'2 days ago', type:'wallet', isRead: true),
    _NotifItem(id:'n9', title:'New Restaurant Near You 🍛', body:'Bombay Bites just opened 0.3 km from you. Get 20% off on first order!', time:'3 days ago', type:'offer', isRead: true),
    _NotifItem(id:'n10', title:'Weekend Special 🎉', body:'30% off on all orders above ₹399 this weekend only!', time:'4 days ago', type:'promo', isRead: true),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<_NotifItem> get _unread => _all.where((n) => !n.isRead).toList();
  List<_NotifItem> get _offers => _all.where((n) => n.type == 'offer' || n.type == 'promo').toList();

  void _markAllRead() => setState(() { for (var n in _all) {
    n.isRead = true;
  } });

  @override
  Widget build(BuildContext context) {
    final unreadCount = _unread.length;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'All (${_all.length})'),
            Tab(text: unreadCount > 0 ? 'Unread ($unreadCount)' : 'Unread'),
            const Tab(text: 'Offers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _NotifList(items: _all, onTap: _onTap, onDismiss: _onDismiss),
          _unread.isEmpty
              ? _emptyState('No unread notifications', '🔔', 'You\'re all caught up!')
              : _NotifList(items: _unread, onTap: _onTap, onDismiss: _onDismiss),
          _offers.isEmpty
              ? _emptyState('No offers right now', '🎁', 'Check back soon for deals!')
              : _NotifList(items: _offers, onTap: _onTap, onDismiss: _onDismiss),
        ],
      ),
    );
  }

  void _onTap(_NotifItem n) {
    setState(() => n.isRead = true);
    if (n.type == 'order') context.push('/orders');
    if (n.type == 'ride') context.push('/rides');
    if (n.type == 'wallet') context.push('/wallet');
  }

  void _onDismiss(_NotifItem n) => setState(() => _all.remove(n));

  Widget _emptyState(String title, String emoji, String sub) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(emoji, style: const TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text(sub, style: const TextStyle(color: AppColors.textSecondary)),
    ]));
  }
}

class _NotifList extends StatelessWidget {
  final List<_NotifItem> items;
  final void Function(_NotifItem) onTap;
  final void Function(_NotifItem) onDismiss;
  const _NotifList({required this.items, required this.onTap, required this.onDismiss});

  static const Map<String, IconData> _icons = {
    'order': Icons.receipt_long_rounded,
    'offer': Icons.local_offer_rounded,
    'promo': Icons.campaign_rounded,
    'ride': Icons.directions_car_rounded,
    'booking': Icons.confirmation_number_rounded,
    'wallet': Icons.account_balance_wallet_rounded,
  };

  static const Map<String, Color> _colors = {
    'order': Color(0xFF4CAF50),
    'offer': Color(0xFFFF6F00),
    'promo': Color(0xFFE91E63),
    'ride': Color(0xFF2196F3),
    'booking': Color(0xFF7C4DFF),
    'wallet': Color(0xFF009688),
  };

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final n = items[i];
        final color = _colors[n.type] ?? AppColors.primary;
        final icon = _icons[n.type] ?? Icons.notifications_rounded;
        return Dismissible(
          key: Key(n.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDismiss(n),
          background: Container(
            alignment: Alignment.centerRight,
            color: Colors.red,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          child: GestureDetector(
            onTap: () => onTap(n),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: n.isRead ? Colors.white : color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: n.isRead ? null : Border.all(color: color.withValues(alpha: 0.2)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(n.title,
                        style: TextStyle(fontSize: 13, fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800))),
                    Text(n.time, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 4),
                  Text(n.body, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ])),
                if (!n.isRead) ...[
                  const SizedBox(width: 8),
                  Container(width: 8, height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                ],
              ]),
            ),
          ),
        );
      },
    );
  }
}