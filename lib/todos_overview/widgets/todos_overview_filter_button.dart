import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/todos_overview/notifier/todos_overview_notifier.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';

class TodosOverviewFilterButton extends ConsumerWidget {
  const TodosOverviewFilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final activeFilter = ref.watch(todosOverviewNotifierProvider).filter;

    return PopupMenuButton<TodosViewFilter>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      initialValue: activeFilter,
      tooltip: l10n.todosOverviewFilterTooltip,
      onSelected: (filter) {
        ref.read(todosOverviewNotifierProvider.notifier).changeFilter(filter);
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: TodosViewFilter.all,
            child: Text(l10n.todosOverviewFilterAll),
          ),
          PopupMenuItem(
            value: TodosViewFilter.activeOnly,
            child: Text(l10n.todosOverviewFilterActiveOnly),
          ),
          PopupMenuItem(
            value: TodosViewFilter.completedOnly,
            child: Text(l10n.todosOverviewFilterCompletedOnly),
          ),
        ];
      },
      icon: const Icon(Icons.filter_list_rounded),
    );
  }
}
