// lib/screens/profile/points_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        final points = auth.user?.points ?? 1280;
        final cashback = (points * 0.01).toStringAsFixed(2);

        final history = [
          {'emoji': '🍔', 'title': 'Food Order #1042', 'pts': '+120', 'date': '10 Jun 2026', 'color': 0xFF4CAF50},
          {'emoji': '🎬', 'title': 'Movie Booking', 'pts': '+50', 'date': '08 Jun 2026', 'color': 0xFF4CAF50},
          {'emoji': '🏨', 'title': 'Hotel Stay – Mumbai', 'pts': '+200', 'date': '01 Jun 2026', 'color': 0xFF4CAF50},
          {'emoji': '⭐', 'title': 'Review Submitted', 'pts': '+20', 'date': '28 May 2026', 'color': 0xFF4CAF50},
          {'emoji': '🛒', 'title': 'Points Redeemed', 'pts': '-100', 'date': '20 May 2026', 'color': 0xFFE53935},
          {'emoji': '👥', 'title': 'Referral Bonus', 'pts': '+100', 'date': '15 May 2026', 'color': 0xFF4CAF50},
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            title: const Text('My Points',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Points card
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6F00), Color(0xFFFFB300)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6F00).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(children: [
                  const Text('⭐', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 8),
                  Text(
                    '$points',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1),
                  ),
                  const Text('Total Points',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '= ₹$cashback cashback value',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              // How to earn
              const Text('How to Earn Points',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...[
                {'emoji': '🍔', 'text': 'Order food — 1 point per ₹1 spent'},
                {'emoji': '🎬', 'text': 'Book movies — 5 points per ticket'},
                {'emoji': '🏨', 'text': 'Hotel booking — 10 points per night'},
                {'emoji': '⭐', 'text': 'Write a review — 20 points'},
                {'emoji': '👥', 'text': 'Refer a friend — 100 points'},
              ].map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6)
                      ],
                    ),
                    child: Row(children: [
                      Text(item['emoji']!,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item['text']!,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  )),

              const SizedBox(height: 24),

              // History
              const Text('Points History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8)
                  ],
                ),
                child: Column(
                  children: history.asMap().entries.map((e) {
                    final i = e.key;
                    final item = e.value;
                    final isPositive = (item['pts'] as String).startsWith('+');
                    return Column(children: [
                      ListTile(
                        leading: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: Color(item['color'] as int)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(item['emoji'] as String,
                                style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                        title: Text(item['title'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                        subtitle: Text(item['date'] as String,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                        trailing: Text(
                          item['pts'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: isPositive
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFE53935),
                          ),
                        ),
                      ),
                      if (i < history.length - 1)
                        const Divider(height: 1, indent: 66),
                    ]);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}