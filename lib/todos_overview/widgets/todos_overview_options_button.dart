import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/todos_overview/notifier/todos_overview_notifier.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';

@visibleForTesting
enum TodosOverviewOption { toggleAll, clearCompleted }

class TodosOverviewOptionsButton extends ConsumerWidget {
  const TodosOverviewOptionsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    // final todos = context.select((TodosOverviewBloc bloc) => bloc.state.todos);
    final todos = ref.watch(todosOverviewNotifierProvider).todos;
    final hasTodos = todos.isNotEmpty;
    final completedTodosAmount = todos.where((todo) => todo.isCompleted).length;

    return PopupMenuButton<TodosOverviewOption>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      tooltip: l10n.todosOverviewOptionsTooltip,
      onSelected: (options) {
        switch (options) {
          case TodosOverviewOption.toggleAll:
            // context.read<TodosOverviewBloc>().add(const TodosOverviewToggleAllRequested());
            ref.read(todosOverviewNotifierProvider.notifier).toggleAll();
          case TodosOverviewOption.clearCompleted:
            // context.read<TodosOverviewBloc>().add(const TodosOverviewClearCompletedRequested());
            ref.read(todosOverviewNotifierProvider.notifier).clearCompleted();
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: TodosOverviewOption.toggleAll,
            enabled: hasTodos,
            child: Text(
              completedTodosAmount == todos.length
                  ? l10n.todosOverviewOptionsMarkAllIncomplete
                  : l10n.todosOverviewOptionsMarkAllComplete,
            ),
          ),
          PopupMenuItem(
            value: TodosOverviewOption.clearCompleted,
            enabled: hasTodos && completedTodosAmount > 0,
            child: Text(l10n.todosOverviewOptionsClearCompleted),
          ),
        ];
      },
      icon: const Icon(Icons.more_vert_rounded),
    );
  }
}
