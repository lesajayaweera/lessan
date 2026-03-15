class ChatSession {
  final String id;
  final String userId;
  final String title;
  final String lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'open', 'resolved', 'pending'
  final String? issueCategory;

  ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'open',
    this.issueCategory,
  });

  ChatSession copyWith({
    String? lastMessage,
    DateTime? updatedAt,
    String? status,
  }) {
    return ChatSession(
      id: id,
      userId: userId,
      title: title,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      issueCategory: issueCategory,
    );
  }
}
