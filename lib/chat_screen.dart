import 'package:flutter/material.dart';
import 'package:project/chat_provider.dart';
import 'package:project/message_bubble.dart';
import 'package:project/typing_indicator.dart';
import 'package:provider/provider.dart';


class ChatScreen extends StatefulWidget {
  final String? sessionId;
  final String? title;
  final String? initialMessage;

  const ChatScreen({
    super.key,
    this.sessionId,
    this.title,
    this.initialMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    if (widget.sessionId != null) {
      _sessionStarted = true;
    } else if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendFirstMessage(widget.initialMessage!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendFirstMessage(String text) async {
    final provider = context.read<ChatProvider>();
    await provider.startNewSession(text);
    setState(() => _sessionStarted = true);
    await provider.sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    final provider = context.read<ChatProvider>();

    if (!_sessionStarted) {
      await _sendFirstMessage(text);
    } else {
      await provider.sendMessage(text);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title ?? 'New Issue',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Text('AI Support Assistant',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'resolve') {
                final provider = context.read<ChatProvider>();
                final messenger = ScaffoldMessenger.of(context);
                await provider.markResolved();
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                      content: Text('Issue marked as resolved'),
                      backgroundColor: Colors.green),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'resolve',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Mark as Resolved'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.error != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.error!),
                        backgroundColor: Colors.red,
                        action: SnackBarAction(
                          label: 'Dismiss',
                          onPressed: provider.clearError,
                          textColor: Colors.white,
                        ),
                      ),
                    );
                    provider.clearError();
                  });
                }

                if (!_sessionStarted && widget.initialMessage == null) {
                  return _buildWelcomeScreen();
                }

                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 16),
                  itemCount: provider.messages.length +
                      (provider.isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.messages.length &&
                        provider.isSending) {
                      return const TypingIndicator();
                    }
                    return MessageBubble(
                        message: provider.messages[index]);
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    final suggestions = [
      'My room Wi-Fi is not working',
      'The bathroom tap is leaking',
      'Air conditioning is too cold',
      'Washing machine is broken',
      'I lost my room key',
      'There is a noise complaint',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.support_agent,
                size: 44, color: Color(0xFF1A237E)),
          ),
          const SizedBox(height: 16),
          const Text('How can I help you today?',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E))),
          const SizedBox(height: 8),
          const Text(
            'Describe your issue or choose from common problems below',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Common Issues',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A237E),
                    fontSize: 14)),
          ),
          const SizedBox(height: 12),
          ...suggestions.map((s) => _SuggestionTile(
                text: s,
                onTap: () => _sendFirstMessage(s),
              )),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FB),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Describe your issue...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<ChatProvider>(
            builder: (context, provider, _) => GestureDetector(
              onTap: provider.isSending ? null : _sendMessage,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: provider.isSending
                      ? Colors.grey
                      : const Color(0xFF1A237E),
                  shape: BoxShape.circle,
                ),
                child: provider.isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionTile({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: const Icon(Icons.arrow_forward_ios,
            size: 14, color: Color(0xFF1A237E)),
        title: Text(text, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}
