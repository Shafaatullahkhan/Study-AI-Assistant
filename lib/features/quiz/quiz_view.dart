import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/ai/ai_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/quizzes_repository.dart';
import 'quiz_view_model.dart';

class QuizView extends StatelessWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuizViewModel(
        context.read<AiRepository>(),
        context.read<QuizzesRepository>(),
      ),
      child: const _QuizBody(),
    );
  }
}

class _QuizBody extends StatelessWidget {
  const _QuizBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QuizViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topic',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: viewModel.topicController,
              decoration: const InputDecoration(
                hintText: 'Flutter navigation, AI basics...',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : viewModel.generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Generate Quiz'),
              ),
            ),
            const SizedBox(height: 16),
            if (viewModel.currentQuiz != null)
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final question =
                        viewModel.currentQuiz!.questions[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.question,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ...question.options.map(
                            (option) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('• $option'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Answer: ${question.answer}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: viewModel.currentQuiz!.questions.length,
                ),
              )
            else
              const Spacer(),
          ],
        ),
      ),
    );
  }
}
