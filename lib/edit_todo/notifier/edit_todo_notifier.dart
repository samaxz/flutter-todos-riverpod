import 'package:equatable/equatable.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todos_repository/todos_repository.dart';

part 'edit_todo_notifier.g.dart';
part 'edit_todo_state.dart';

// overriding dependencies for testing purposes and to explicitly list all the dependencies
@Riverpod(dependencies: [todosRepository])
class EditTodoNotifier extends _$EditTodoNotifier {
  @override
  EditTodoState build(Todo? initialTodo) {
    return EditTodoState(initialTodo: initialTodo);
  }

  void changeTitle(String? newTitle) {
    state = state.copyWith(
      initialTodo: state.initialTodo?.copyWith(title: newTitle),
      title: newTitle,
    );
  }

  void changeDescription(String? newDescription) {
    // this modifies description of newly added and initial (current) todo
    state = state.copyWith(
      initialTodo: state.initialTodo?.copyWith(description: newDescription),
      description: newDescription,
    );
  }

  Future<void> submitTodo() async {
    state = state.copyWith(status: EditTodoStatus.loading);
    final todo = (state.initialTodo ?? Todo(title: '')).copyWith(
      // todo's values will be set to these - so, i need to modify them
      title: state.initialTodo?.title ?? state.title,
      description: state.initialTodo?.description ?? state.description,
    );
    try {
      await ref.read(todosRepositoryProvider).saveTodo(todo);
      state = state.copyWith(status: EditTodoStatus.success);
    } catch (e) {
      state = state.copyWith(status: EditTodoStatus.failure);
    }
  }
}
