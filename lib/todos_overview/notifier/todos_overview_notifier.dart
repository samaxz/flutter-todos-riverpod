import 'package:equatable/equatable.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:flutter_todos/todos_overview/models/todos_view_filter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todos_repository/todos_repository.dart';

part 'todos_overview_notifier.g.dart';
part 'todos_overview_state.dart';

@riverpod
class TodosOverviewNotifier extends _$TodosOverviewNotifier {
  @override
  TodosOverviewState build() {
    return const TodosOverviewState();
  }

  Future<void> requestSubscription() async {
    state = state.copyWith(status: () => TodosOverviewStatus.loading);

    ref.read(todosRepositoryProvider).getTodos().listen(
      (todos) {
        state = state.copyWith(
          status: () => TodosOverviewStatus.success,
          todos: () => todos,
        );
      },
      onError: (_, __) => state = state.copyWith(status: () => TodosOverviewStatus.failure),
    );
  }

  Future<void> toggleCompletion(
    Todo todo, {
    required bool isCompleted,
  }) async {
    final newTodo = todo.copyWith(isCompleted: isCompleted);
    await ref.read(todosRepositoryProvider).saveTodo(newTodo);
  }

  Future<void> delete(Todo todo) async {
    state = state.copyWith(lastDeletedTodo: () => todo);
    await ref.read(todosRepositoryProvider).deleteTodo(todo.id);
  }

  Future<void> requestUndoDeletion() async {
    assert(
      state.lastDeletedTodo != null,
      'Last deleted todo can not be null.',
    );

    final todo = state.lastDeletedTodo!;
    state = state.copyWith(lastDeletedTodo: () => null);
    await ref.read(todosRepositoryProvider).saveTodo(todo);
  }

  Future<void> changeFilter(TodosViewFilter filter) async {
    state = state.copyWith(filter: () => filter);
  }

  Future<void> toggleAll() async {
    final areAllCompleted = state.todos.every((todo) => todo.isCompleted);
    await ref.read(todosRepositoryProvider).completeAll(isCompleted: !areAllCompleted);
  }

  Future<void> clearCompleted() async {
    await ref.read(todosRepositoryProvider).clearCompleted();
  }
}
