import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/study_task_model.dart';
import 'planner_view_model.dart';

class PlannerView extends StatelessWidget {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          PlannerViewModel(context.read(), context.read()),
      child: const _PlannerBody(),
    );
  }
}

class _PlannerBody extends StatelessWidget {
  const _PlannerBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlannerViewModel>();

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => _TaskEditor(
                onSave: viewModel.addOrUpdateTask,
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            children: [
              SectionHeader(
                title: 'Study Planner',
                actionText: 'Add task',
                onAction: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => _TaskEditor(
                      onSave: viewModel.addOrUpdateTask,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
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
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: viewModel.focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(day, viewModel.selectedDay),
                  onDaySelected: (selectedDay, focusedDay) {
                    viewModel.setSelectedDay(selectedDay);
                    viewModel.setFocusedDay(focusedDay);
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tasks for selected day',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final task = viewModel.tasksForSelectedDay[index];
                    return Container(
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
                            width: 8,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _statusColor(task.status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.subject,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  task.task,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (task.reminderAt != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Reminder: ${_formatTime(task.reminderAt!)}'
                                      '${task.recurrence == RecurrenceRule.none ? '' : ' • ${task.recurrence.name}'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ),
                                if (task.repeatUntil != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Until ${_formatDate(task.repeatUntil!)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDate(task.date),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              _StatusChip(status: task.status),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (_) => _TaskEditor(
                                          task: task,
                                          onSave: viewModel.addOrUpdateTask,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        viewModel.deleteTask(task),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: viewModel.tasksForSelectedDay.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final StudyTaskStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final text = switch (status) {
      StudyTaskStatus.pending => 'Pending',
      StudyTaskStatus.inProgress => 'In Progress',
      StudyTaskStatus.done => 'Done',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

Color _statusColor(StudyTaskStatus status) {
  return switch (status) {
    StudyTaskStatus.pending => AppColors.secondary,
    StudyTaskStatus.inProgress => AppColors.accent,
    StudyTaskStatus.done => AppColors.primary,
  };
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}';
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class _TaskEditor extends StatefulWidget {
  const _TaskEditor({
    this.task,
    required this.onSave,
  });

  final StudyTaskModel? task;
  final Future<void> Function({
    String? id,
    required String subject,
    required String task,
    required DateTime date,
    required StudyTaskStatus status,
    DateTime? reminderAt,
    RecurrenceRule recurrence,
    DateTime? repeatUntil,
  }) onSave;

  @override
  State<_TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<_TaskEditor> {
  late final TextEditingController _subjectController;
  late final TextEditingController _taskController;
  late DateTime _date;
  late StudyTaskStatus _status;
  DateTime? _reminderAt;
  RecurrenceRule _recurrence = RecurrenceRule.none;
  DateTime? _repeatUntil;

  @override
  void initState() {
    super.initState();
    _subjectController =
        TextEditingController(text: widget.task?.subject ?? '');
    _taskController = TextEditingController(text: widget.task?.task ?? '');
    _date = widget.task?.date ?? DateTime.now();
    _status = widget.task?.status ?? StudyTaskStatus.pending;
    _reminderAt = widget.task?.reminderAt;
    _recurrence = widget.task?.recurrence ?? RecurrenceRule.none;
    _repeatUntil = widget.task?.repeatUntil;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.task == null ? 'Add task' : 'Edit task',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _taskController,
            decoration: const InputDecoration(labelText: 'Task'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setState(() => _date = picked);
                    }
                  },
                  child: Text('Date: ${_formatDate(_date)}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<StudyTaskStatus>(
                  value: _status,
                  items: StudyTaskStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        _reminderAt ?? DateTime.now(),
                      ),
                    );
                    if (time != null) {
                      setState(() {
                        _reminderAt = DateTime(
                          _date.year,
                          _date.month,
                          _date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: Text(
                    _reminderAt == null
                        ? 'Add reminder'
                        : 'Reminder ${_formatTime(_reminderAt!)}',
                  ),
                ),
              ),
              if (_reminderAt != null) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => setState(() => _reminderAt = null),
                  icon: const Icon(Icons.close),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<RecurrenceRule>(
            value: _recurrence,
            items: RecurrenceRule.values
                .map(
                  (rule) => DropdownMenuItem(
                    value: rule,
                    child: Text(rule.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _recurrence = value);
              }
            },
            decoration: const InputDecoration(labelText: 'Recurrence'),
          ),
          if (_recurrence != RecurrenceRule.none) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _repeatUntil ?? _date,
                        firstDate: _date,
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() {
                          _repeatUntil = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            _repeatUntil?.hour ?? _date.hour,
                            _repeatUntil?.minute ?? _date.minute,
                          );
                        });
                      }
                    },
                    child: Text(
                      _repeatUntil == null
                          ? 'Repeat until (date)'
                          : 'Until ${_formatDate(_repeatUntil!)}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          _repeatUntil ?? DateTime.now(),
                        ),
                      );
                      if (time != null) {
                        final base = _repeatUntil ?? _date;
                        setState(() {
                          _repeatUntil = DateTime(
                            base.year,
                            base.month,
                            base.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                    child: Text(
                      _repeatUntil == null
                          ? 'Repeat until (time)'
                          : 'Until ${_formatTime(_repeatUntil!)}',
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_reminderAt != null &&
                    _repeatUntil != null &&
                    !_repeatUntil!.isAfter(_reminderAt!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Repeat-until time must be after the first reminder.',
                      ),
                    ),
                  );
                  return;
                }
                await widget.onSave(
                  id: widget.task?.id,
                  subject: _subjectController.text.trim(),
                  task: _taskController.text.trim(),
                  date: _date,
                  status: _status,
                  reminderAt: _reminderAt,
                  recurrence: _recurrence,
                  repeatUntil: _repeatUntil,
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Save Task'),
            ),
          ),
        ],
      ),
    );
  }
}
