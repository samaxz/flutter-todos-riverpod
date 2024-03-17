import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todos_repository/todos_repository.dart';

part 'edit_todo_notifier.g.dart';
part 'edit_todo_state.dart';

@riverpod
class EditTodoNotifier extends _$EditTodoNotifier {
  @override
  EditTodoState build(Todo? initialTodo) {
    return EditTodoState(initialTodo: initialTodo);
  }

  Future<void> changeTitle(String? newTitle) async {
    state = state.copyWith(
      initialTodo: state.initialTodo?.copyWith(title: newTitle),
      title: newTitle,
    );
    // final todo = Todo(
    //   title: newTitle ?? state.title,
    //   description: state.description,
    // );
    // await ref.read(todosRepositoryProvider).saveTodo(todo);
    log('changeTitle()');
  }

  Future<void> changeDescription(String? newDescription) async {
    state = state.copyWith(
      initialTodo: state.initialTodo?.copyWith(description: newDescription),
      description: newDescription,
    );
    // final todo = Todo(
    //   title: state.title,
    //   // title: state.initialTodo?.title ?? state.title,
    //   description: newDescription ?? state.description,
    // );
    // await ref.read(todosRepositoryProvider).saveTodo(todo);
    log('changeDescription()');
  }

  // TODO remoe the passed in todo and use state's instead
  Future<void> submitTodo(Todo newTodo) async {
    state = state.copyWith(status: EditTodoStatus.loading);
    final todo = (state.initialTodo ?? Todo(title: '')).copyWith(
      // todo's values will be set to these - so, i need to modify them
      // title: 'state.title',
      title: newTodo.title,
      // description: 'state.description',
      description: newTodo.description,
    );
    log('new title: ${newTodo.title}');
    log('new description: ${newTodo.description}');
    // this is not needed
    // TODO remove this
    final initialTodo = state.initialTodo?.copyWith(
      title: newTodo.title,
      description: newTodo.description,
    );
    try {
      await ref.read(todosRepositoryProvider).saveTodo(todo);
      state = state.copyWith(
        status: EditTodoStatus.success,
        title: todo.title,
        description: todo.description,
        // not sure i need this
        // initialTodo: todo,
        initialTodo: initialTodo,
      );
    } catch (e) {
      state = state.copyWith(status: EditTodoStatus.failure);
    }
  }
}
