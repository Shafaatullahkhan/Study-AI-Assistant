import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../chat/chat_view.dart';
import '../home/home_view.dart';
import '../planner/planner_view.dart';
import '../tools/tools_view.dart';
import 'root_view_model.dart';

class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RootViewModel(),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RootViewModel>();
    final pages = const [
      HomeView(),
      ChatView(),
      ToolsView(),
      PlannerView(),
    ];

    return Scaffold(
      body: pages[viewModel.index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: viewModel.index,
        onDestinationSelected: viewModel.setIndex,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            label: 'AI Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_mosaic_outlined),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            label: 'Planner',
          ),
        ],
      ),
    );
  }
}
