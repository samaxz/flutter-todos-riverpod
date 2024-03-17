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
    state = state.copyWith(title: newTitle);
    // final todo = Todo(
    //   title: newTitle ?? state.title,
    //   description: state.description,
    // );
    // await ref.read(todosRepositoryProvider).saveTodo(todo);
    log('changeTitle()');
  }

  Future<void> changeDescription(String? newDescription) async {
    state = state.copyWith(description: newDescription);
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
    // log('1) title: ${state.title}');
    // log('1) description: ${state.description}');
    final todo = (state.initialTodo ?? Todo(title: '')).copyWith(
      // final todo = (state.initialTodo ?? newTodo).copyWith(
      // i think this is where things take the wrong turn
      title: state.title,
      // title: newTodo.title.isEmpty ? state.title : newTodo.title,
      description: state.description,
      // description: newTodo.description,
    );
    // log('initial title: ${state.initialTodo?.title}');
    // log('2) title: ${todo.title}');
    // log('2) description: ${todo.description}');
    try {
      await ref.read(todosRepositoryProvider).saveTodo(todo);
      state = state.copyWith(
        status: EditTodoStatus.success,
        title: todo.title,
        description: todo.description,
        initialTodo: todo,
      );
      // log('todo state title inside notifier: ${state.title}');
      // log('todo state description inside notifier: ${state.description}');
      // log('is new todo inside notifier: ${state.isNewTodo}');
    } catch (e) {
      state = state.copyWith(status: EditTodoStatus.failure);
    }
  }
}
