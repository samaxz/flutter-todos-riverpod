import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/edit_todo/view/edit_todo_page.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/todos_overview/notifier/todos_overview_notifier.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';

class TodosOverviewPage extends ConsumerStatefulWidget {
  const TodosOverviewPage({super.key});

  @override
  ConsumerState createState() => _TodosOverviewPageState();
}

class _TodosOverviewPageState extends ConsumerState<TodosOverviewPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(todosOverviewNotifierProvider.notifier).requestSubscription(),
    );
  }

  Widget buildBody(WidgetRef ref, BuildContext context) {
    final l10n = context.l10n;
    final todosOverview = ref.watch(todosOverviewNotifierProvider);

    if (todosOverview.todos.isEmpty) {
      if (todosOverview.status == TodosOverviewStatus.loading) {
        return const Center(child: CupertinoActivityIndicator());
      } else if (todosOverview.status != TodosOverviewStatus.success) {
        return const SizedBox();
      } else {
        return Center(
          child: Text(
            l10n.todosOverviewEmptyText,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }
    }

    return CupertinoScrollbar(
      child: ListView(
        children: [
          for (final todo in todosOverview.filteredTodos)
            TodoListTile(
              todo: todo,
              onToggleCompleted: (isCompleted) {
                final notifier = ref.read(todosOverviewNotifierProvider.notifier);
                notifier.toggleCompletion(
                  todo,
                  isCompleted: isCompleted,
                );
              },
              onDismissed: (_) {
                ref.read(todosOverviewNotifierProvider.notifier).delete(todo);
              },
              onTap: () {
                Navigator.of(context).push(
                  EditTodoPage.route(initialTodo: todo),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(todosOverviewNotifierProvider, (previous, next) {
      if (previous != null &&
          previous.status != next.status &&
          next.status == TodosOverviewStatus.failure) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.todosOverviewErrorSnackbarText),
            ),
          );
      }
      if (previous != null &&
          previous.lastDeletedTodo != next.lastDeletedTodo &&
          next.lastDeletedTodo != null) {
        final deletedTodo = next.lastDeletedTodo!;
        final messenger = ScaffoldMessenger.of(context);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                l10n.todosOverviewTodoDeletedSnackbarText(
                  deletedTodo.title,
                ),
              ),
              action: SnackBarAction(
                label: l10n.todosOverviewUndoDeletionButtonText,
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  ref.read(todosOverviewNotifierProvider.notifier).requestUndoDeletion();
                },
              ),
            ),
          );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todosOverviewAppBarTitle),
        actions: const [
          TodosOverviewFilterButton(),
          TodosOverviewOptionsButton(),
        ],
      ),
      body: buildBody(ref, context),
    );
  }
}
