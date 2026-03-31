import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final String greeting = 'Hey, Shafaat';
  final String subtitle = 'Let’s power up your study session today.';

  final List<String> quickTips = [
    'Summarize your notes in seconds.',
    'Generate a quiz before exams.',
    'Plan study blocks for focused time.',
  ];
}
