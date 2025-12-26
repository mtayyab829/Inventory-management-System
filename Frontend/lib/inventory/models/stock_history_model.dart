import 'package:cloud_firestore/cloud_firestore.dart';

/// Stock history entry representing a stock change event
class StockHistory {
  final String? historyId;
  final String productId;
  final String userId;
  final String action; // 'stock_in', 'stock_out', 'created', 'updated', 'deleted'
  final int quantityChange; // positive for stock in, negative for stock out
  final int previousQuantity;
  final int newQuantity;
  final String? notes;
  final DateTime timestamp;

  StockHistory({
    this.historyId,
    required this.productId,
    required this.userId,
    required this.action,
    required this.quantityChange,
    required this.previousQuantity,
    required this.newQuantity,
    this.notes,
    required this.timestamp,
  });

  /// Create StockHistory from Firestore document
  factory StockHistory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return StockHistory(
      historyId: doc.id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      action: data['action'] ?? '',
      quantityChange: data['quantityChange'] ?? 0,
      previousQuantity: data['previousQuantity'] ?? 0,
      newQuantity: data['newQuantity'] ?? 0,
      notes: data['notes'],
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert StockHistory to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'userId': userId,
      'action': action,
      'quantityChange': quantityChange,
      'previousQuantity': previousQuantity,
      'newQuantity': newQuantity,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Get action display name
  String get actionDisplayName {
    switch (action) {
      case 'stock_in':
        return 'Stock In';
      case 'stock_out':
        return 'Stock Out';
      case 'created':
        return 'Product Created';
      case 'updated':
        return 'Product Updated';
      case 'deleted':
        return 'Product Deleted';
      default:
        return action;
    }
  }

  /// Get action icon
  String get actionIcon {
    switch (action) {
      case 'stock_in':
        return '➕';
      case 'stock_out':
        return '➖';
      case 'created':
        return '🆕';
      case 'updated':
        return '✏️';
      case 'deleted':
        return '🗑️';
      default:
        return '📝';
    }
  }

  /// Get action color
  int get actionColor {
    switch (action) {
      case 'stock_in':
        return 0xFF10B981; // Green
      case 'stock_out':
        return 0xFFF59E0B; // Orange
      case 'created':
        return 0xFF3B82F6; // Blue
      case 'updated':
        return 0xFF8B5CF6; // Purple
      case 'deleted':
        return 0xFFEF4444; // Red
      default:
        return 0xFF6B7280; // Gray
    }
  }

  /// Format quantity change for display
  String get quantityChangeDisplay {
    if (action == 'created' || action == 'updated' || action == 'deleted') {
      return '';
    }
    final sign = quantityChange > 0 ? '+' : '';
    return '$sign$quantityChange';
  }

  /// Get formatted timestamp
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
