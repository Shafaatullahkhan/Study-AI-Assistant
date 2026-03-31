import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/feature_card.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/repositories/flashcards_repository.dart';
import '../../data/repositories/notes_repository.dart';
import '../../data/repositories/quizzes_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/voice_notes_repository.dart';
import '../flashcards/flashcards_view.dart';
import '../flashcards/flashcards_view_model.dart';
import '../quiz/quiz_view.dart';
import '../quiz/quiz_view_model.dart';
import '../settings/settings_view.dart';
import '../settings/settings_view_model.dart';
import '../summarizer/summarizer_view.dart';
import '../summarizer/summarizer_view_model.dart';
import '../voice_notes/voice_notes_view.dart';
import '../voice_notes/voice_notes_view_model.dart';
import 'home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'AI Study Assistant',
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
                                create: (context) => SettingsViewModel(
                                  context.read<SettingsRepository>(),
                                ),
                                child: const SettingsView(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _HeroHeader(viewModel: viewModel),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: const SectionHeader(
                title: 'Quick Actions',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                final columns = width > 840
                    ? 3
                    : width > 560
                        ? 2
                        : 1;
                final spacing = 16.0;
                final itemWidth =
                    (width - spacing * (columns - 1)) / columns;

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: itemWidth / 150,
                  ),
                  delegate: SliverChildListDelegate(
                    [
                      FeatureCard(
                        title: 'AI Chatbot',
                        subtitle: 'Ask anything, get clarity.',
                        icon: Icons.smart_toy_rounded,
                        tint: AppColors.secondary,
                      ),
                      FeatureCard(
                        title: 'Summarizer',
                        subtitle: 'Turn long notes into key points.',
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
                        subtitle: 'Speak and capture ideas fast.',
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
                        subtitle: 'Practice with AI-made quizzes.',
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
                        title: 'Study Planner',
                        subtitle: 'Stay on top of tasks.',
                        icon: Icons.event_note_rounded,
                        tint: AppColors.primary,
                      ),
                      FeatureCard(
                        title: 'Flashcards',
                        subtitle: 'Quick review, anytime.',
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
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: const SectionHeader(
                title: 'Today at a Glance',
                actionText: 'View plan',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 720;
                      return Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              label: 'Tasks due',
                              value: '4',
                              icon: Icons.task_alt_rounded,
                              tint: AppColors.primary,
                            ),
                          ),
                          if (isWide) const SizedBox(width: 16),
                          if (isWide)
                            Expanded(
                              child: MetricCard(
                                label: 'Study minutes',
                                value: '90',
                                icon: Icons.timer_rounded,
                                tint: AppColors.secondary,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            viewModel.quickTips.first,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See more'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            viewModel.greeting,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            viewModel.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Ask AI to explain a topic…',
              prefixIcon: const Icon(Icons.search_rounded),
              fillColor: Colors.white,
              prefixIconColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
