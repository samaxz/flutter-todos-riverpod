import 'package:equatable/equatable.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todos_repository/todos_repository.dart';

part 'edit_todo_provider.g.dart';
part 'edit_todo_state.dart';

@riverpod
class EditTodo extends _$EditTodo {
  @override
  EditTodoState build() {
    return const EditTodoState();
  }

  void changeTitle(String? newTitle) {
    state = state.copyWith(title: newTitle);
  }

  void changeDescription(String? newDescription) {
    state = state.copyWith(description: newDescription);
  }

  Future<void> submitTodo() async {
    state = state.copyWith(status: EditTodoStatus.loading);
    final todo = (state.initialTodo ?? Todo(title: '')).copyWith(
      title: state.title,
      description: state.description,
    );
    try {
      await ref.read(todosRepositoryProvider).saveTodo(todo);
      state = state.copyWith(status: EditTodoStatus.success);
    } catch (e) {
      state = state.copyWith(status: EditTodoStatus.failure);
    }
  }
}
