import 'package:flutter/material.dart';
import '../../../domain/ai/external_ai_service.dart';
import '../../../domain/models/chat_message.dart';
import '../../theme/app_theme.dart';

class EcobotChatScreen extends StatefulWidget {
  const EcobotChatScreen({super.key});

  @override
  State<EcobotChatScreen> createState() => _EcobotChatScreenState();
}

class _EcobotChatScreenState extends State<EcobotChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initWelcome();
  }

  void _initWelcome() {
    _messages.add(
      ChatMessage(
        id: 'welcome_0',
        sender: MessageSender.bot,
        text:
            'Hello! I am **EcoBot**, your local zero-cost e-waste advisor. 🤖🌱\n\n'
            'I can guide you on data sanitization, lithium-ion battery safety, precious metals recovery, and certified drop-off logistics.\n\n'
            'Ask me anything or tap one of the suggested prompts below!',
        timestamp: DateTime.now(),
        suggestions: const [
          'How do I wipe my data before recycling?',
          'My battery is swollen or leaking, what do I do?',
          'What precious metals are recovered from e-waste?',
          'How does doorstep pickup work?',
          'What are R2 and e-Stewards certifications?',
        ],
      ),
    );
  }

  void _sendMessage(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: MessageSender.user,
          text: text,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();

    // Query AI service (offline local engine by default)
    final aiResponse = await ExternalAiService.askAssistant(text);

    await Future.delayed(const Duration(milliseconds: 300)); // Natural micro-pause

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          sender: MessageSender.bot,
          text: aiResponse.text,
          timestamp: DateTime.now(),
          suggestions: aiResponse.suggestions,
        ),
      );
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('EcoBot AI Assistant'),
            SizedBox(width: 8),
            Text('🌱', style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.lightMint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 14, color: AppTheme.primaryGreen),
                SizedBox(width: 2),
                Text(
                  '100% Offline / Zero API Cost',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.sender == MessageSender.user;

                return Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('🤖', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? AppTheme.primaryGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isUser
                                    ? const Radius.circular(16)
                                    : const Radius.circular(4),
                                bottomRight: isUser
                                    ? const Radius.circular(4)
                                    : const Radius.circular(16),
                              ),
                              border: isUser
                                  ? null
                                  : Border.all(color: AppTheme.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: isUser ? Colors.white : AppTheme.textLight,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Follow-up suggestion prompt chips
                    if (!isUser && msg.suggestions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 40, bottom: 12),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: msg.suggestions.map((s) {
                            return ActionChip(
                              label: Text(s),
                              labelStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryGreen,
                              ),
                              backgroundColor: const Color(0xFFF0FDF4),
                              side: const BorderSide(
                                  color: Color(0xFFBBF7D0), width: 1),
                              onPressed: () => _sendMessage(s),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accentMint,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'EcoBot is preparing advice...',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Text entry field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: 'Ask about data wiping, batteries, or value...',
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  onPressed: () => _sendMessage(_inputController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
