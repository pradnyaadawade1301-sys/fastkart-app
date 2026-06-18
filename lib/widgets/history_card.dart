// lib/widgets/history_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/history_item.dart';
import 'status_badge.dart';

class HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback? onReorder;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const HistoryCard({
    super.key,
    required this.item,
    this.onReorder,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canReorder = item.extra['canReorder'] == true;
    final fmt = DateFormat('d MMM, h:mm a');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 3),
                        Text('${item.subtitle} · ${fmt.format(item.date)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(item.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#${item.id}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  Text('₹${item.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
              if (canReorder && onReorder != null) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: onReorder,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF97316),
                    side: const BorderSide(color: Color(0xFFF97316)),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Reorder'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}