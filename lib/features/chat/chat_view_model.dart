import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/ai/ai_repository.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel(this._aiRepository);

  final AiRepository _aiRepository;

  final List<ChatMessage> messages = [
    ChatMessage(
      isUser: false,
      text: 'Hi! Ask me anything about your studies.',
    ),
  ];

  bool _loading = false;
  bool get isLoading => _loading;
  double _speed = 1.0;
  double get speed => _speed;
  bool _paused = false;
  bool get isPaused => _paused;

  StreamSubscription<String>? _subscription;
  Timer? _flushTimer;
  StringBuffer _pending = StringBuffer();
  ChatMessage? _streamingMessage;

  void setSpeed(double value) {
    _speed = value;
    notifyListeners();
  }

  void togglePause() {
    _paused = !_paused;
    notifyListeners();
  }

  void clearBuffer() {
    _pending = StringBuffer();
    notifyListeners();
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    messages.add(ChatMessage(isUser: true, text: text.trim()));
    _loading = true;
    notifyListeners();

    try {
      _streamingMessage = ChatMessage(isUser: false, text: '');
      messages.add(_streamingMessage!);
      _subscription?.cancel();
    _subscription = _aiRepository.chatStream(text.trim()).listen(
      (delta) {
        _pending.write(delta);
      },
        onError: (error) {
          messages.add(ChatMessage(isUser: false, text: 'Error: $error'));
          stop();
        },
        onDone: () {
          stop();
        },
      );
      _startFlushTimer();
    } catch (error) {
      messages.add(
        ChatMessage(
          isUser: false,
          text: 'Error: ${error.toString()}',
        ),
      );
    } finally {
      // Loading state is managed by stop() for streaming lifecycle.
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _flushTimer?.cancel();
    _flushTimer = null;
    _pending = StringBuffer();
    _streamingMessage = null;
    _loading = false;
    _paused = false;
    notifyListeners();
  }

  void _startFlushTimer() {
    _flushTimer?.cancel();
    final interval = Duration(milliseconds: (50 / _speed).clamp(20, 120).toInt());
    _flushTimer = Timer.periodic(interval, (_) {
      if (_paused) return;
      if (_streamingMessage == null) return;
      if (_pending.isEmpty) return;
      final chunkSize = (_speed * 6).round().clamp(1, 20);
      final text = _pending.toString();
      final take = text.length < chunkSize ? text.length : chunkSize;
      final chunk = text.substring(0, take);
      _streamingMessage!.text += chunk;
      _pending = StringBuffer(text.substring(take));
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _flushTimer?.cancel();
    super.dispose();
  }
}

class ChatMessage {
  ChatMessage({required this.isUser, required this.text});

  final bool isUser;
  String text;
}
