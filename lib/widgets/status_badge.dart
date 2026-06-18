// lib/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../models/history_item.dart';

class StatusBadge extends StatelessWidget {
  final HistoryStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _config[status] ?? _config[HistoryStatus.pending]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(config.$3,
          style: TextStyle(color: config.$2, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  static const Map<HistoryStatus, (Color, Color, String)> _config = {
    HistoryStatus.delivered: (Color(0xFFEAF3DE), Color(0xFF3B6D11), 'Delivered'),
    HistoryStatus.confirmed: (Color(0xFFE6F1FB), Color(0xFF185FA5), 'Confirmed'),
    HistoryStatus.completed: (Color(0xFFEAF3DE), Color(0xFF3B6D11), 'Completed'),
    HistoryStatus.cancelled: (Color(0xFFFAEEDA), Color(0xFF854F0B), 'Cancelled'),
    HistoryStatus.pending:   (Color(0xFFFAEEDA), Color(0xFF854F0B), 'Pending'),
    HistoryStatus.watched:   (Color(0xFFE6F1FB), Color(0xFF185FA5), 'Watched'),
    HistoryStatus.paid:      (Color(0xFFEAF3DE), Color(0xFF3B6D11), 'Paid'),
    HistoryStatus.success:   (Color(0xFFEAF3DE), Color(0xFF3B6D11), 'Success'),
    HistoryStatus.expired:   (Color(0xFFFCEBEB), Color(0xFFA32D2D), 'Expired'),
  };
}