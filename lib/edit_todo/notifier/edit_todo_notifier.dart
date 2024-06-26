import 'package:equatable/equatable.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todos_repository/todos_repository.dart';

part 'edit_todo_notifier.g.dart';
part 'edit_todo_state.dart';

// for unit and widget testing
class MockEditTodoNotifier extends _$EditTodoNotifier with Mock implements EditTodoNotifier {
  // this works with both container and the mock notifier, but the the former throws
  // ```Pending timers:``` (probably cause i don't listen to it at the beginning)
  @override
  Future<void> submitTodo() => Future.value();

  @override
  EditTodoState build({Todo? initialTodo}) {
    return EditTodoState(
      initialTodo: initialTodo,
      // used for widget test
      status: EditTodoStatus.success,
    );
  }
}

// overriding dependencies for testing purposes and to explicitly list all the dependencies
@Riverpod(dependencies: [todosRepository])
class EditTodoNotifier extends _$EditTodoNotifier {
  @override
  // it has a default positioned value of null
  // this is the default value returned by the notifier
  EditTodoState build({Todo? initialTodo}) {
    return EditTodoState(
      initialTodo: initialTodo,
      title: '',
      description: '',
    );
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
