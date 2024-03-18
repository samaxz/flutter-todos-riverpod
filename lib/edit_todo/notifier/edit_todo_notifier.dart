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
    // log('changeTitle()');
  }

  Future<void> changeDescription(String? newDescription) async {
    // this modifier description of the current todo
    state = state.copyWith(
      initialTodo: state.initialTodo?.copyWith(description: newDescription),
      description: newDescription,
    );
    // log('changeDescription()');
  }

  Future<void> submitTodo() async {
    state = state.copyWith(status: EditTodoStatus.loading);
    final todo = (state.initialTodo ?? Todo(title: '')).copyWith(
      // todo's values will be set to these - so, i need to modify them
      title: state.initialTodo?.title ?? state.title,
      description: state.initialTodo?.description ?? state.description,
    );
    // log('new title: ${newTodo.title}');
    // log('new description: ${newTodo.description}');
    try {
      await ref.read(todosRepositoryProvider).saveTodo(todo);
      state = state.copyWith(status: EditTodoStatus.success);
    } catch (e) {
      state = state.copyWith(status: EditTodoStatus.failure);
    }
  }
}
