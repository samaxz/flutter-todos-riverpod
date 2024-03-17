import 'package:equatable/equatable.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todos_repository/todos_repository.dart';

part 'stats_notifier.g.dart';
part 'stats_state.dart';

@riverpod
class StatsNotifier extends _$StatsNotifier {
  @override
  StatsState build() {
    return const StatsState();
  }

  Future<void> requestSubscription() async {
    state = state.copyWith(status: StatsStatus.loading);

    ref.read(todosRepositoryProvider).getTodos().listen(
      (todos) {
        state = state.copyWith(
          status: StatsStatus.success,
          completedTodos: todos.where((todo) => todo.isCompleted).length,
          activeTodos: todos.where((todo) => !todo.isCompleted).length,
        );
      },
      onError: (_, __) => state = state.copyWith(status: StatsStatus.failure),
    );
  }
}