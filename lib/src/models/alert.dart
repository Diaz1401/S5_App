class Alert {
  final String id;
  final String title;
  final String description;
  final String severity; // 'info', 'warning', 'critical'
  final DateTime timestamp;
  final bool isRead;

  const Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
  });

  Alert copyWith({
    String? id,
    String? title,
    String? description,
    String? severity,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
