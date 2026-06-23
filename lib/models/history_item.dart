// lib/models/history_item.dart

enum HistoryCategory {
  food,
  movies,
  hotels,
  leisure,
  ride,
  bike,
  travel,
  grocery,
  more,
}

enum HistoryStatus {
  delivered,
  confirmed,
  completed,
  cancelled,
  pending,
  watched,
  paid,
  success,
  expired,
}

class HistoryItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final DateTime date;
  final double amount;
  final HistoryStatus status;
  final HistoryCategory category;
  final String? imageUrl;
  final Map<String, dynamic> extra;

  const HistoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.date,
    required this.amount,
    required this.status,
    required this.category,
    this.imageUrl,
    this.extra = const {},
  });

  HistoryItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    DateTime? date,
    double? amount,
    HistoryStatus? status,
    HistoryCategory? category,
    String? imageUrl,
    Map<String, dynamic>? extra,
  }) {
    return HistoryItem(
      id:          id          ?? this.id,
      title:       title       ?? this.title,
      subtitle:    subtitle    ?? this.subtitle,
      description: description ?? this.description,
      date:        date        ?? this.date,
      amount:      amount      ?? this.amount,
      status:      status      ?? this.status,
      category:    category    ?? this.category,
      imageUrl:    imageUrl    ?? this.imageUrl,
      extra:       extra       ?? this.extra,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':          id,
    'title':       title,
    'subtitle':    subtitle,
    'description': description,
    'date':        date.toIso8601String(),
    'amount':      amount,
    'status':      status.name,
    'category':    category.name,
    'imageUrl':    imageUrl,
    'extra':       extra,
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id:          json['id'] as String,
      title:       json['title'] as String,
      subtitle:    json['subtitle'] as String,
      description: json['description'] as String,
      date:        DateTime.parse(json['date'] as String),
      // BUG FIX: amount was missing — caused crash on fromJson
      amount:      (json['amount'] as num?)?.toDouble() ?? 0.0,
      // BUG FIX: byName throws if string doesn't match — wrapped in try-catch
      status:      _parseStatus(json['status'] as String? ?? ''),
      category:    _parseCategory(json['category'] as String? ?? ''),
      imageUrl:    json['imageUrl'] as String?,
      extra:       (json['extra'] as Map<String, dynamic>?) ?? {},
    );
  }
}

HistoryStatus _parseStatus(String str) {
  try {
    return HistoryStatus.values.byName(str);
  } catch (_) {
    return HistoryStatus.pending;
  }
}

HistoryCategory _parseCategory(String str) {
  try {
    return HistoryCategory.values.byName(str);
  } catch (_) {
    return HistoryCategory.more;
  }
}