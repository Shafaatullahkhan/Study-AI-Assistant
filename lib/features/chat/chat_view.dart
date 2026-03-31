import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/ai/ai_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../settings/settings_view.dart';
import '../settings/settings_view_model.dart';
import 'chat_view_model.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ChatViewModel(context.read<AiRepository>()),
      child: const _ChatBody(),
    );
  }
}

class _ChatBody extends StatefulWidget {
  const _ChatBody();

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatViewModel>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  'AI Chatbot',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (context) =>
                              SettingsViewModel(
                                context.read<SettingsRepository>(),
                              ),
                          child: const SettingsView(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings_rounded),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Online',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              itemBuilder: (context, index) {
                final message = viewModel.messages[index];
                final alignment =
                    message.isUser ? Alignment.centerRight : Alignment.centerLeft;
                final color =
                    message.isUser ? AppColors.primary : AppColors.secondary;

                return Align(
                  alignment: alignment,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: viewModel.messages.length,
            ),
          ),
          if (viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: _TypingIndicator(),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            decoration: const BoxDecoration(
              color: AppColors.background,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Speed'),
                    const SizedBox(width: 8),
                    DropdownButton<double>(
                      value: viewModel.speed,
                      items: const [
                        DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                        DropdownMenuItem(value: 1.0, child: Text('1x')),
                        DropdownMenuItem(value: 2.0, child: Text('2x')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.setSpeed(value);
                        }
                      },
                    ),
                    const Spacer(),
                    if (viewModel.isLoading)
                      TextButton.icon(
                        onPressed: viewModel.stop,
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text('Stop'),
                      ),
                    if (viewModel.isLoading)
                      TextButton.icon(
                        onPressed: viewModel.togglePause,
                        icon: Icon(
                          viewModel.isPaused
                              ? Icons.play_circle_outline
                              : Icons.pause_circle_outline,
                        ),
                        label: Text(viewModel.isPaused ? 'Resume' : 'Pause'),
                      ),
                    if (viewModel.isLoading)
                      TextButton.icon(
                        onPressed: viewModel.clearBuffer,
                        icon: const Icon(Icons.cleaning_services_outlined),
                        label: const Text('Clear buffer'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your question…',
                          prefixIcon: const Icon(Icons.auto_awesome),
                          fillColor: AppColors.card,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        onPressed: () {
                          final text = _controller.text;
                          _controller.clear();
                          viewModel.send(text);
                        },
                        icon:
                            const Icon(Icons.send_rounded, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _dot1;
  late final Animation<double> _dot2;
  late final Animation<double> _dot3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _dot1 = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)),
    );
    _dot2 = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8)),
    );
    _dot3 = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Dot(animation: _dot1),
        const SizedBox(width: 6),
        _Dot(animation: _dot2),
        const SizedBox(width: 6),
        _Dot(animation: _dot3),
      ],
    );
  }
}

class _Dot extends AnimatedWidget {
  const _Dot({required Animation<double> animation})
      : super(listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: animation.value,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
