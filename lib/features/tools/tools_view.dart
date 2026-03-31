import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/feature_card.dart';
import '../../data/repositories/flashcards_repository.dart';
import '../../data/repositories/notes_repository.dart';
import '../../data/repositories/quizzes_repository.dart';
import '../../data/repositories/voice_notes_repository.dart';
import '../flashcards/flashcards_view.dart';
import '../flashcards/flashcards_view_model.dart';
import '../quiz/quiz_view.dart';
import '../quiz/quiz_view_model.dart';
import '../summarizer/summarizer_view.dart';
import '../summarizer/summarizer_view_model.dart';
import '../voice_notes/voice_notes_view.dart';
import '../voice_notes/voice_notes_view_model.dart';

class ToolsView extends StatelessWidget {
  const ToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Study Tools',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 720 ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2,
                  children: [
                    FeatureCard(
                      title: 'Notes Summarizer',
                      subtitle: 'Condense long notes instantly.',
                      icon: Icons.subject_rounded,
                      tint: AppColors.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SummarizerView(),
                          ),
                        );
                      },
                    ),
                    FeatureCard(
                      title: 'Voice Notes',
                      subtitle: 'Record and transcribe ideas.',
                      icon: Icons.mic_rounded,
                      tint: AppColors.accent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VoiceNotesView(),
                          ),
                        );
                      },
                    ),
                    FeatureCard(
                      title: 'Quiz Generator',
                      subtitle: 'Practice with AI quizzes.',
                      icon: Icons.quiz_rounded,
                      tint: AppColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuizView(),
                          ),
                        );
                      },
                    ),
                    FeatureCard(
                      title: 'Flashcards',
                      subtitle: 'Quick revision cards.',
                      icon: Icons.style_rounded,
                      tint: AppColors.accent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FlashcardsView(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
