enum MessageRole { user, assistant }

class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      content: map['content'] ?? '',
      role: map['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'role': role == MessageRole.user ? 'user' : 'assistant',
      'timestamp': timestamp.toIso8601String(),
    };
  }

  ChatMessage copyWith({String? content, bool? isLoading}) {
    return ChatMessage(
      id: id,
      content: content ?? this.content,
      role: role,
      timestamp: timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
