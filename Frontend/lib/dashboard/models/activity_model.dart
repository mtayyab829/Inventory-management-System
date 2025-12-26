import 'package:cloud_firestore/cloud_firestore.dart';

/// Activity entry representing user actions in the inventory system
class Activity {
  final String? activityId;
  final String userId;
  final String type; // 'product_added', 'stock_changed', 'product_updated', 'product_deleted', 'low_stock_alert'
  final String title;
  final String description;
  final String? productId;
  final String? productName;
  final int? quantityChange;
  final DateTime timestamp;

  Activity({
    this.activityId,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    this.productId,
    this.productName,
    this.quantityChange,
    required this.timestamp,
  });

  /// Create Activity from Firestore document
  factory Activity.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Activity(
      activityId: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      productId: data['productId'],
      productName: data['productName'],
      quantityChange: data['quantityChange'],
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert Activity to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'description': description,
      'productId': productId,
      'productName': productName,
      'quantityChange': quantityChange,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Get activity icon
  String get icon {
    switch (type) {
      case 'product_added':
        return '🆕';
      case 'stock_changed':
        return quantityChange != null && quantityChange! > 0 ? '➕' : '➖';
      case 'product_updated':
        return '✏️';
      case 'product_deleted':
        return '🗑️';
      case 'low_stock_alert':
        return '⚠️';
      default:
        return '📝';
    }
  }

  /// Get activity color
  int get color {
    switch (type) {
      case 'product_added':
        return 0xFF10B981; // Green
      case 'stock_changed':
        return quantityChange != null && quantityChange! > 0
            ? 0xFF10B981 // Green for stock in
            : 0xFFF59E0B; // Orange for stock out
      case 'product_updated':
        return 0xFF3B82F6; // Blue
      case 'product_deleted':
        return 0xFFEF4444; // Red
      case 'low_stock_alert':
        return 0xFFF59E0B; // Orange
      default:
        return 0xFF6B7280; // Gray
    }
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

  /// Get activity subtitle (product name if available)
  String? get subtitle {
    if (productName != null && productName!.isNotEmpty) {
      return productName;
    }
    return null;
  }
}
