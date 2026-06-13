// lib/screens/chat/chat_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

class _Message {
  final String id, text, time;
  final bool isUser;
  final String? imageUrl;
  _Message({required this.id, required this.text, required this.time,
      required this.isUser}) : imageUrl = null;
}

class ChatScreen extends StatefulWidget {
  final String type; // 'support' | 'driver'
  const ChatScreen({super.key, this.type = 'support'});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _isTyping = false;
  Timer? _typingTimer;

  final List<_Message> _messages = [
    _Message(id:'m0', text:'Hello! Welcome to FastKart Support 👋\nHow can I help you today?',
        time:'10:00 AM', isUser: false),
  ];

  final List<String> _quickReplies = [
    'Track my order',
    'Cancel order',
    'Refund status',
    'Report an issue',
    'Talk to agent',
  ];

  static const Map<String, String> _autoReplies = {
    'track': 'Sure! Please share your Order ID and I\'ll track it for you. 📦',
    'cancel': 'I can help you cancel your order. Please note cancellations after 2 min of placement may not be possible. Share your Order ID.',
    'refund': 'Refunds are processed within 5-7 business days to your original payment method. Share your Order ID to check status.',
    'issue': 'I\'m sorry to hear that! Please describe the issue in detail and I\'ll escalate it to the right team. 🙏',
    'agent': 'Connecting you to a live agent... ⏳\nEstimated wait time: 2-3 minutes.',
    'hello': 'Hi there! 😊 How can I assist you today?',
    'hi': 'Hello! 👋 What can I help you with?',
    'thanks': 'You\'re welcome! Is there anything else I can help you with? 😊',
    'help': 'I can help you with order tracking, cancellations, refunds, and more. What do you need?',
  };

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    final now = TimeOfDay.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.period.name.toUpperCase()}';

    setState(() {
      _messages.add(_Message(id: 'm${_messages.length}', text: text.trim(), time: timeStr, isUser: true));
      _isTyping = true;
    });
    _ctrl.clear();
    _scrollDown();

    // Auto-reply after delay
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1200), () {
      final reply = _getReply(text.toLowerCase());
      setState(() {
        _isTyping = false;
        _messages.add(_Message(id: 'm${_messages.length}', text: reply, time: timeStr, isUser: false));
      });
      _scrollDown();
    });
  }

  String _getReply(String text) {
    for (final key in _autoReplies.keys) {
      if (text.contains(key)) return _autoReplies[key]!;
    }
    return 'Thank you for reaching out! Our team will look into this shortly. Your query reference number is #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}. 📋';
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSupport = widget.type == 'support';
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Row(children: [
          Container(width: 36, height: 36,
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: Center(child: Text(isSupport ? '🎧' : '🛵', style: const TextStyle(fontSize: 18)))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isSupport ? 'FastKart Support' : 'Your Driver',
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            Row(children: [
              Container(width: 7, height: 7,
                  decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('Online', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ]),
        ]),
        actions: [
          if (!isSupport)
            IconButton(icon: const Icon(Icons.call_rounded, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert_rounded, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (_, i) {
              if (_isTyping && i == _messages.length) return _TypingBubble();
              return _MessageBubble(msg: _messages[i]);
            },
          ),
        ),

        // Quick replies (show only if last message is from bot)
        if (_messages.isNotEmpty && !_messages.last.isUser && !_isTyping)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _send(_quickReplies[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(_quickReplies[i],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),

        // Input
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SafeArea(
            top: false,
            child: Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(24)),
                  child: TextField(
                    controller: _ctrl,
                    maxLines: 3, minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: AppColors.textHint),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: _send,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _send(_ctrl.text),
                child: Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFB300)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(width: 30, height: 30,
              decoration: const BoxDecoration(color: Color(0xFFFF6F00), shape: BoxShape.circle),
              child: const Center(child: Text('🎧', style: TextStyle(fontSize: 14)))),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(msg.text,
                    style: TextStyle(
                        fontSize: 13,
                        color: msg.isUser ? Colors.black87 : AppColors.textPrimary,
                        height: 1.4)),
                const SizedBox(height: 4),
                Text(msg.time,
                    style: TextStyle(fontSize: 9,
                        color: msg.isUser ? Colors.black45 : AppColors.textHint)),
              ]),
            ),
          ),
          if (msg.isUser) const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
  }
  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(width: 30, height: 30,
          decoration: const BoxDecoration(color: Color(0xFFFF6F00), shape: BoxShape.circle),
          child: const Center(child: Text('🎧', style: TextStyle(fontSize: 14)))),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)]),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) =>
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.translate(
                  offset: Offset(0, i == 1 ? -4 * _anim.value : (i == 0 ? -2 * _anim.value : -3 * _anim.value)),
                  child: Container(width: 7, height: 7,
                      decoration: const BoxDecoration(color: AppColors.textSecondary, shape: BoxShape.circle)),
                ),
              )
            )),
          ),
        ),
      ]),
    );
  }
}