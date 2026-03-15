import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/chat_message.dart';
import 'package:project/chat_service.dart';
import 'package:project/chat_session.dart';


class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatSession> _sessions = [];
  List<ChatMessage> _messages = [];
  String? _currentSessionId;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  StreamSubscription<List<ChatSession>>? _sessionsSubscription;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  List<ChatSession> get sessions => _sessions;
  List<ChatMessage> get messages => _messages;
  String? get currentSessionId => _currentSessionId;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  void init() {
    _sessionsSubscription = _chatService.getUserSessions().listen(
      (sessions) {
        _sessions = sessions;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load sessions: $e';
        notifyListeners();
      },
    );
  }

  Future<String> startNewSession(String firstMessage) async {
    _setLoading(true);
    try {
      final sessionId = await _chatService.createSession(firstMessage);
      _currentSessionId = sessionId;
      _loadMessages(sessionId);
      return sessionId;
    } catch (e) {
      _error = 'Failed to create session: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void openSession(String sessionId) {
    _currentSessionId = sessionId;
    _messages = [];
    notifyListeners();
    _loadMessages(sessionId);
  }

  void _loadMessages(String sessionId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatService.getMessages(sessionId).listen(
      (msgs) {
        _messages = msgs;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load messages: $e';
        notifyListeners();
      },
    );
  }

  Future<void> sendMessage(String text) async {
    if (_currentSessionId == null || text.trim().isEmpty) return;

    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      await _chatService.sendMessage(_currentSessionId!, text.trim());
    } catch (e) {
      _error = 'Failed to send message. Please try again.';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> markResolved() async {
    if (_currentSessionId == null) return;
    await _chatService.markResolved(_currentSessionId!);
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    await _chatService.deleteSession(sessionId);
    if (_currentSessionId == sessionId) {
      _currentSessionId = null;
      _messages = [];
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
