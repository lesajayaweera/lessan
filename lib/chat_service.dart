import 'dart:async';
import 'package:project/chat_message.dart';
import 'package:project/chat_session.dart';
import 'ai_service.dart';

/// In-memory chat service — no Firebase required.
class ChatService {
  // In-memory stores
  final Map<String, ChatSession> _sessions = {};
  final Map<String, List<ChatMessage>> _messages = {};
  int _nextSessionId = 1;
  int _nextMessageId = 1;

  // Stream controllers so the UI stays reactive
  final _sessionsController =
      StreamController<List<ChatSession>>.broadcast();
  final Map<String, StreamController<List<ChatMessage>>> _msgControllers = {};

  static const String _userId = 'local_user';

  // ─── Sessions ─────────────────────────────────────────────────────────────

  Stream<List<ChatSession>> getUserSessions() {
    // Emit current state immediately, then future updates
    Future.microtask(_emitSessions);
    return _sessionsController.stream;
  }

  void _emitSessions() {
    final sorted = _sessions.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _sessionsController.add(sorted);
  }

  Future<String> createSession(String firstMessage) async {
    final id = 'session_${_nextSessionId++}';
    final category = AIService.detectIssueCategory(firstMessage);
    final title = _generateTitle(firstMessage);
    final now = DateTime.now();

    _sessions[id] = ChatSession(
      id: id,
      userId: _userId,
      title: title,
      lastMessage: firstMessage,
      createdAt: now,
      updatedAt: now,
      status: 'open',
      issueCategory: category,
    );
    _messages[id] = [];
    _emitSessions();
    return id;
  }

  Future<void> updateSession(String sessionId, String lastMessage,
      {String? status}) async {
    final session = _sessions[sessionId];
    if (session == null) return;
    _sessions[sessionId] = session.copyWith(
      lastMessage: lastMessage,
      updatedAt: DateTime.now(),
      status: status,
    );
    _emitSessions();
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.remove(sessionId);
    _messages.remove(sessionId);
    _msgControllers[sessionId]?.close();
    _msgControllers.remove(sessionId);
    _emitSessions();
  }

  Future<void> markResolved(String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) return;
    _sessions[sessionId] = session.copyWith(
      status: 'resolved',
      updatedAt: DateTime.now(),
    );
    _emitSessions();
  }

  // ─── Messages ─────────────────────────────────────────────────────────────

  Stream<List<ChatMessage>> getMessages(String sessionId) {
    _msgControllers[sessionId] ??=
        StreamController<List<ChatMessage>>.broadcast();
    Future.microtask(() => _emitMessages(sessionId));
    return _msgControllers[sessionId]!.stream;
  }

  void _emitMessages(String sessionId) {
    final ctrl = _msgControllers[sessionId];
    if (ctrl == null || ctrl.isClosed) return;
    ctrl.add(List.unmodifiable(_messages[sessionId] ?? []));
  }

  Future<void> _saveMessage(String sessionId, ChatMessage message) async {
    _messages.putIfAbsent(sessionId, () => []);
    final id = 'msg_${_nextMessageId++}';
    _messages[sessionId]!.add(ChatMessage(
      id: id,
      content: message.content,
      role: message.role,
      timestamp: message.timestamp,
    ));
    _emitMessages(sessionId);
  }

  List<Map<String, String>> _getConversationHistory(String sessionId) {
    final msgs = _messages[sessionId] ?? [];
    final recent = msgs.length > 20 ? msgs.sublist(msgs.length - 20) : msgs;
    return recent
        .map((m) => {
              'role': m.role == MessageRole.user ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();
  }

  /// Sends user message, saves it, fetches AI reply, and saves AI reply.
  Future<String> sendMessage(String sessionId, String userText) async {
    // Save user message
    final userMessage = ChatMessage(
      id: '',
      content: userText,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    await _saveMessage(sessionId, userMessage);
    await updateSession(sessionId, userText);

    // Get conversation history for context
    final history = _getConversationHistory(sessionId);

    // Get AI response
    final aiText = await AIService.getResponse(history, userText);

    // Save AI message
    final aiMessage = ChatMessage(
      id: '',
      content: aiText,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );
    await _saveMessage(sessionId, aiMessage);
    await updateSession(sessionId, aiText);

    return aiText;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _generateTitle(String message) {
    if (message.length <= 40) return message;
    return '${message.substring(0, 37)}...';
  }

  void dispose() {
    _sessionsController.close();
    for (final ctrl in _msgControllers.values) {
      ctrl.close();
    }
  }
}
