import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:mocktail/mocktail.dart';

part 'edit_todo_notifier.g.dart';
part 'edit_todo_state.dart';

// TODO remove this
class AltMockEditTodoNotifier extends EditTodoNotifier with Mock {
  // @override
  // // EditTodoState get state => super.state;
  // EditTodoState get state => EditTodoState();
  // // EditTodoState get state {
  // //   // this causes stack overflow
  // //   // debugPrint('$state getter inside mock notifier');
  // //   return EditTodoState();
  // // }
  //
  // @override
  // set state(EditTodoState value) {
  //   super.state = value;
  //   // this causes stack overflow
  //   // state = value;
  //   debugPrint('$state setter inside mock notifier');
  // }
}

// this throws
// class SomeMock extends Mock implements EditTodoNotifier {}

// could theoretically use this too
// class SomeMock extends EditTodoNotifier {
//   set debugState(EditTodoState value) {
//     state = value;
//   }
// }
//
// final someMockNP = StateNotifierProvider<EditTodoNotifier, EditTodoState>((ref) => SomeMock());

// TODO remove this
// final mockEditTodoNotifier = MockEditTodoNotifier();

// TODO remove this
// for unit testing
class MockEditTodoNotifier extends _$EditTodoNotifier with Mock implements EditTodoNotifier {
  // this works
  // without this, i'm getting ```type 'Null' is not a subtype of type 'EditTodoState'```
  // @override
  // EditTodoState build({Todo? initialTodo}) {
  //   // debugPrint('$state inside mock notifier');
  //   return EditTodoState(
  //     initialTodo: initialTodo,
  //     title: initialTodo?.title ?? '',
  //     description: initialTodo?.description ?? '',
  //   );
  //   // return super.noSuchMethod(
  //   //   Invocation.method(
  //   //     #build,
  //   //     [],
  //   //   ),
  //   //   // returnValue: Future.value([]),
  //   // );
  // }
  //
  // //
  // @override
  // // EditTodoState get state => super.state;
  // EditTodoState get state {
  //   // this causes stack overflow
  //   // debugPrint('$state getter inside mock notifier');
  //   return EditTodoState();
  // }
  //
  // @override
  // set state(EditTodoState value) {
  //   super.state = value;
  //   // this causes stack overflow
  //   // state = value;
  //   debugPrint('$state setter inside mock notifier');
  // }
  //
  // @override
  // Future<void> submitTodo() async {
  //   // await Future.value();
  //   // debugPrint('submitTodo() called inside mock notifier');
  //   // this should be overridden, so, no worries (hopefully)
  //   await ref.read(todosRepositoryProvider).saveTodo(Todo(title: ''));
  // }

  // @override
  // EditTodoState setTodo(Todo todo) {
  //   return EditTodoState(
  //     initialTodo: todo,
  //     title: todo.title,
  //     description: todo.description,
  //   );
  // }
  //
  // @override
  // // void setNewState(Todo todo) {
  // void setNewState(EditTodoState newState) {
  //   // state = state.copyWith(
  //   //   initialTodo: todo,
  //   //   title: todo.title,
  //   //   description: todo.description,
  //   // );
  //   // state = EditTodoState(
  //   //   initialTodo: todo,
  //   //   title: todo.title,
  //   //   description: todo.description,
  //   // );
  //   state = newState;
  // }

  // @override
  // void setNewState(EditTodoState newState) {
  //   state = newState;
  //   debugPrint('$state inside mock notifier after setNewState');
  // }
}

// overriding dependencies for testing purposes and to explicitly list all the dependencies
@Riverpod(dependencies: [todosRepository])
class EditTodoNotifier extends _$EditTodoNotifier {
  @override
  // it has a default positioned value of null
  EditTodoState build({Todo? initialTodo}) {
    // debugPrint('$state inside original notifier');
    return EditTodoState(
      initialTodo: initialTodo,
      title: initialTodo?.title ?? '',
      description: initialTodo?.description ?? '',
    );
    // this is done for testing purposes
    throw UnimplementedError();
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

  // used to set state in tests
  // TODO remove this
  EditTodoState setTodo(Todo todo) {
    state = state.copyWith(
      initialTodo: todo,
      title: todo.title,
      description: todo.description,
    );
    return state;
  }

  // void setNewState(Todo todo) {
  //   state = state.copyWith(
  //     initialTodo: todo,
  //     title: todo.title,
  //     description: todo.description,
  //   );
  // }

  // TODO remove this
  void setNewState(EditTodoState newState) => state = newState;
}
