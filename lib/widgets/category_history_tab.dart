// lib/widgets/category_history_tab.dart
import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';
import 'history_card.dart';

class CategoryHistoryTab extends StatefulWidget {
  final HistoryCategory category;
  final IconData emptyIcon;
  final String emptyMessage;
  final String emptySubtitle;
  final String? emptyButtonLabel;
  final VoidCallback? onEmptyAction;

  const CategoryHistoryTab({
    super.key,
    required this.category,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.emptySubtitle,
    this.emptyButtonLabel,
    this.onEmptyAction,
  });

  @override
  State<CategoryHistoryTab> createState() => _CategoryHistoryTabState();
}

class _CategoryHistoryTabState extends State<CategoryHistoryTab>
    with AutomaticKeepAliveClientMixin {

  List<HistoryItem> _items = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => false; // false rakho taaki tab switch pe reload ho

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load(); // har baar tab visible hone pe reload
  }

  Future<void> _load() async {
    final items = await HistoryService.instance.getByCategory(widget.category);
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  Future<void> _delete(String id) async {
    await HistoryService.instance.deleteItem(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF97316)),
      );
    }

    if (_items.isEmpty) {
      return _EmptyState(
        icon: widget.emptyIcon,
        message: widget.emptyMessage,
        subtitle: widget.emptySubtitle,
        buttonLabel: widget.emptyButtonLabel,
        onAction: widget.onEmptyAction,
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFF97316),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (_, i) => HistoryCard(
          item: _items[i],
          onDelete: () => _delete(_items[i].id),
          onReorder: _items[i].extra['canReorder'] == true ? () {} : null,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
    this.buttonLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: const Color(0xFFF97316)),
            ),
            const SizedBox(height: 20),
            Text(message,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A)),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                textAlign: TextAlign.center),
            if (buttonLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(buttonLabel!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}