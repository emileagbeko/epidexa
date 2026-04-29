import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/epidexa_scaffold.dart';
import '../../case_flow/providers/active_case_provider.dart';

class CaseContext {
  const CaseContext({
    required this.caseId,
    required this.title,
    required this.patientPresentation,
    this.additionalHistory,
    required this.correctDiagnosis,
    required this.userDiagnosis,
    this.diagnosisCorrect,
    this.nextStepCorrect,
    required this.keyVisualCues,
  });

  final String caseId;
  final String title;
  final String patientPresentation;
  final String? additionalHistory;
  final String correctDiagnosis;
  final String? userDiagnosis;
  final bool? diagnosisCorrect;
  final bool? nextStepCorrect;
  final List<String> keyVisualCues;

  Map<String, dynamic> toJson() => {
        'title': title,
        'patientPresentation': patientPresentation,
        'additionalHistory': additionalHistory,
        'correctDiagnosis': correctDiagnosis,
        'userDiagnosis': userDiagnosis,
        'diagnosisCorrect': diagnosisCorrect,
        'nextStepCorrect': nextStepCorrect,
        'keyVisualCues': keyVisualCues,
      };
}

class _ChatMessage {
  const _ChatMessage({
    required this.content,
    required this.isUser,
  });

  final String content;
  final bool isUser;
}

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key, this.caseContext});

  final CaseContext? caseContext;

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isOnAssistantScreenProvider.notifier).state = true;
    });
    // Seed opening message
    final greeting = widget.caseContext != null
        ? "I can see you've just worked through the **${widget.caseContext!.title}** case. "
            "What would you like to explore further? I can explain the diagnosis, "
            "key visual features, or why certain management steps are preferred."
        : "Hello. I'm your dermatology teaching assistant. "
            "Ask me anything about skin conditions, clinical features, or diagnostic reasoning.";

    _messages.add(_ChatMessage(content: greeting, isUser: false));
  }

  @override
  void dispose() {
    ref.read(isOnAssistantScreenProvider.notifier).state = false;
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add(_ChatMessage(content: text, isUser: true));
      _loading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => !m.isUser || m != _messages.last)
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.content})
          .toList();

      // Include the new user message
      history.add({'role': 'user', 'content': text});

      final body = <String, dynamic>{'messages': history};
      if (widget.caseContext != null) {
        body['caseContext'] = widget.caseContext!.toJson();
      }

      final res = await http.post(
        Uri.parse('${AppConstants.supabaseUrl}/functions/v1/chat'),
        headers: {
          'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final reply = json['reply'] as String? ?? 'Sorry, I could not get a response.';

      setState(() {
        _messages.add(_ChatMessage(content: reply, isUser: false));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          content: 'Something went wrong. Please try again.',
          isUser: false,
        ));
        _loading = false;
      });
    }

    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    return EpidexaScaffold(
      title: 'AI Assistant',
      bottomPadding: false,
      body: Column(
        children: [
          if (widget.caseContext != null) _CaseContextBanner(context: widget.caseContext!),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return msg.isUser
                    ? _UserBubble(message: msg.content)
                    : _AiBubble(message: msg.content);
              },
            ),
          ),
          if (_loading) const _TypingIndicator(),
          _ChatInput(
            controller: _controller,
            enabled: !_loading,
            onSend: _send,
            hint: widget.caseContext != null
                ? 'Ask about this case...'
                : 'Ask about dermatology...',
          ),
        ],
      ),
    );
  }
}

class _CaseContextBanner extends StatelessWidget {
  const _CaseContextBanner({required this.context});

  final CaseContext context;

  @override
  Widget build(BuildContext bContext) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.plumLight,
      child: Row(
        children: [
          Icon(Icons.smart_toy_rounded, size: 14, color: AppColors.plum),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Discussing: ${context.title}',
              style: AppTextStyles.caption.copyWith(color: AppColors.plum),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: MarkdownBody(
          data: message,
          styleSheet: MarkdownStyleSheet(
            p: AppTextStyles.body,
            strong: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            em: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic),
            listBullet: AppTextStyles.body,
            blockquote: AppTextStyles.body.copyWith(color: AppColors.mutedText),
            h3: AppTextStyles.subheading,
            h4: AppTextStyles.subheading,
          ),
          shrinkWrap: true,
        ),
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.plum,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.surface),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 64, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 150),
            const SizedBox(width: 4),
            _Dot(delay: 300),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.delay});

  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween(begin: 0.3, end: 1.0).animate(_anim);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _anim.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.mutedText,
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.enabled,
    required this.onSend,
    required this.hint,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.caption,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.plum, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedOpacity(
            opacity: enabled ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 150),
            child: Material(
              color: AppColors.plum,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: enabled ? onSend : null,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
