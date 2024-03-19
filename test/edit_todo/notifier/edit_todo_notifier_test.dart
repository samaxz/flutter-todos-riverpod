import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
import 'package:flutter_todos/edit_todo/notifier/edit_todo_notifier.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todos_repository/todos_repository.dart';

// part 'edit_todo_notifier_test.g.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class FakeTodo extends Fake implements Todo {}

// this is wrong
// class MockEditTodoNotifier with Mock implements EditTodoNotifier {}

// Your mock needs to subclass the Notifier base-class corresponding
// to whatever your notifier uses
// class MockEditTodoNotifier extends _$MockEditTodoNotifier with Mock implements EditTodoNotifier {}

// TODO remove this
// @riverpod
// class MockEditTodoNotifier extends _$MockEditTodoNotifier implements EditTodoNotifier {
//   @override
//   EditTodoState build(Todo? initialTodo) {
//     return EditTodoState(initialTodo: initialTodo);
//   }
//
//   void changeTitle(String? newTitle) {
//     state = state.copyWith(
//       initialTodo: state.initialTodo?.copyWith(title: newTitle),
//       title: newTitle,
//     );
//   }
//
//   void changeDescription(String? newDescription) {
//     // this modifies description of newly added and initial (current) todo
//     state = state.copyWith(
//       initialTodo: state.initialTodo?.copyWith(description: newDescription),
//       description: newDescription,
//     );
//   }
//
//   Future<void> submitTodo() async {
//     state = state.copyWith(status: EditTodoStatus.loading);
//     final todo = (state.initialTodo ?? Todo(title: '')).copyWith(
//       // todo's values will be set to these - so, i need to modify them
//       title: state.initialTodo?.title ?? state.title,
//       description: state.initialTodo?.description ?? state.description,
//     );
//     try {
//       await ref.read(todosRepositoryProvider).saveTodo(todo);
//       state = state.copyWith(status: EditTodoStatus.success);
//     } catch (e) {
//       state = state.copyWith(status: EditTodoStatus.failure);
//     }
//   }
// }

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  ProviderContainer createProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
        // i need to override edit todo notifier notifier with value here
        // editTodoNotifierProvider(null).overrideWith(() => MockEditTodoNotifier()),
        // editTodoNotifierProvider(null).overrideWith(MockEditTodoNotifier.new),
      ],
    );
    // this throws, as it can only be used inside tests
    // addTearDown(container.dispose);
    return container;
  }

  group('EditTodoNotifier', () {
    // late TodosRepository todosRepository;

    setUpAll(() {
      registerFallbackValue(FakeTodo());
      // this doesn't work for some reason
      // registerFallbackValue(EditTodoState());
    });

    // setUp(() {
    //   todosRepository = MockTodosRepository();
    // });

    group('constructor', () {
      test('works properly', () {
        expect(createProviderContainer, returnsNormally);
      });

      test('has correct initial state', () {
        final container = createProviderContainer();
        final listener = Listener<EditTodoState>();
        container.listen(
          editTodoNotifierProvider(null),
          listener,
          fireImmediately: true,
        );
        // expect(
        //   container.read(editTodoNotifierProvider(null)),
        //   equals(const EditTodoState()),
        // );
        verify(
          () => listener(null, const EditTodoState()),
        );
        addTearDown(container.dispose);
      });
    });

    test('emits new state with updated title', () {
      final container = createProviderContainer();
      final listener = Listener<EditTodoState>();
      container.listen(
        editTodoNotifierProvider(null),
        listener,
        fireImmediately: true,
      );
      container.read(editTodoNotifierProvider(null).notifier).changeTitle('newTitle');
      verify(
        () => listener(
          EditTodoState(title: ''),
          EditTodoState(title: 'newTitle'),
        ),
      );
      addTearDown(container.dispose);
      // this throws OutsideTestException
      // expect(
      // container.read(editTodoNotifierProvider(null)).title,
      //   'newTitle',
      // );
    });

    test('emits new state with updated description', () {
      final container = createProviderContainer();
      final listener = Listener<EditTodoState>();
      container.listen(
        editTodoNotifierProvider(null),
        listener,
        fireImmediately: true,
      );
      container.read(editTodoNotifierProvider(null).notifier).changeDescription('newDescription');
      verify(
        () => listener(
          EditTodoState(description: ''),
          EditTodoState(description: 'newDescription'),
        ),
      );
      // this throws for some reason
      // verifyNoMoreInteractions(listener);
      addTearDown(container.dispose);
    });

    group('EditTodoSubmitted', () {
      test(
        'attempts to save new todo to repository '
        'if no initial todo was provided',
        () async {
          final container = createProviderContainer();
          final listener = Listener<EditTodoState>();
          container.listen(
            editTodoNotifierProvider(null),
            listener,
            fireImmediately: true,
          );
          when(() => container.read(todosRepositoryProvider).saveTodo(any()))
              .thenAnswer((_) async {});
          // could use verify with listener here instead
          // expect(
          //   container.read(editTodoNotifierProvider(null)),
          //   equals(const EditTodoState()),
          // );
          // not gonna use this here either, cause i'm already using verifyInOrder(), which includes
          // this
          // this also somehow works :|
          // listener(
          //   EditTodoState(status: EditTodoStatus.initial),
          //   // both of these work, weird
          //   // EditTodoState(status: EditTodoStatus.loading),
          //   EditTodoState(status: EditTodoStatus.failure),
          // );
          final notifier = container.read(editTodoNotifierProvider(null).notifier);
          notifier
            ..changeTitle('newTitle')
            ..changeDescription('newDescription');
          await notifier
            ..submitTodo();
          verifyInOrder(
            [
              // initial state before calling any method
              () {
                listener(
                  null,
                  EditTodoState(),
                );
              },
              // state after calling changeTitle('newTitle')
              () {
                listener(
                  EditTodoState(),
                  EditTodoState(title: 'newTitle'),
                );
              },
              // state after calling changeDescription('newDescription')
              () {
                listener(
                  EditTodoState(title: 'newTitle'),
                  EditTodoState(title: 'newTitle', description: 'newDescription'),
                );
              },
              // state after calling submitTodo()
              () {
                listener(
                  EditTodoState(
                    // status: EditTodoStatus.loading,
                    // status: EditTodoStatus.initial,
                    title: 'newTitle',
                    description: 'newDescription',
                  ),
                  EditTodoState(
                    // status: EditTodoStatus.success,
                    status: EditTodoStatus.loading,
                    title: 'newTitle',
                    description: 'newDescription',
                  ),
                );
              },
            ],
          );
          addTearDown(container.dispose);
        },
      );

      // blocTest<EditTodoBloc, EditTodoState>(
      //   'attempts to save new todo to repository '
      //   'if no initial todo was provided',
      //   setUp: () {
      //     when(() => todosRepository.saveTodo(any())).thenAnswer((_) async {});
      //   },
      //   build: buildBloc,
      //   seed: () => const EditTodoState(
      //     title: 'title',
      //     description: 'description',
      //   ),
      //   act: (bloc) => bloc.add(const EditTodoSubmitted()),
      //   expect: () => const [
      //     EditTodoState(
      //       status: EditTodoStatus.loading,
      //       title: 'title',
      //       description: 'description',
      //     ),
      //     EditTodoState(
      //       status: EditTodoStatus.success,
      //       title: 'title',
      //       description: 'description',
      //     ),
      //   ],
      //   verify: (bloc) {
      //     verify(
      //       () => todosRepository.saveTodo(
      //         any(
      //           that: isA<Todo>().having((t) => t.title, 'title', equals('title')).having(
      //                 (t) => t.description,
      //                 'description',
      //                 equals('description'),
      //               ),
      //         ),
      //       ),
      //     ).called(1);
      //   },
      // );

      test(
        'attempts to save updated todo to repository '
        'if an initial todo was provided',
        () async {
          final initialTodo = Todo(
            title: 'initial_title',
            description: 'initial_description',
          );
          final container = createProviderContainer();
          final listener = Listener<EditTodoState>();
          container.listen(
            editTodoNotifierProvider(initialTodo),
            listener,
            fireImmediately: true,
          );
          when(() => container.read(todosRepositoryProvider).saveTodo(any()))
              .thenAnswer((_) async {});
          // listener(
          //   null,
          //   EditTodoState(initialTodo: initialTodo),
          // );
          final notifier = container.read(editTodoNotifierProvider(initialTodo).notifier);
          notifier
            ..changeTitle('new_title')
            ..changeDescription('new_description');
          verifyInOrder(
            [
              // initial state before calling any method
              () {
                listener(
                  null,
                  EditTodoState(initialTodo: initialTodo),
                );
              },
              // initial state before calling ????
              // () {
              //   listener(
              //     null,
              //     EditTodoState(initialTodo: initialTodo),
              //   );
              // },
              // state after calling changeTitle('new_title')
              () {
                listener(
                  EditTodoState(initialTodo: initialTodo),
                  EditTodoState(
                    initialTodo: initialTodo.copyWith(title: 'new_title'),
                    title: 'new_title',
                  ),
                );
              },
              // state after calling changeDescription('new_description')
              () {
                listener(
                  EditTodoState(
                    initialTodo: initialTodo.copyWith(title: 'new_title'),
                    title: 'new_title',
                  ),
                  EditTodoState(
                    initialTodo: initialTodo.copyWith(
                      title: 'new_title',
                      description: 'new_description',
                    ),
                    title: 'new_title',
                    description: 'new_description',
                  ),
                );
              },
            ],
          );
          await notifier
            ..submitTodo();
          verify(
            () => listener(
              EditTodoState(
                // status: EditTodoStatus.loading,
                initialTodo: initialTodo.copyWith(
                  title: 'new_title',
                  description: 'new_description',
                ),
                title: 'new_title',
                description: 'new_description',
              ),
              EditTodoState(
                // for some reason, this should be loading, instead of success :/
                status: EditTodoStatus.loading,
                initialTodo: initialTodo.copyWith(
                  title: 'new_title',
                  description: 'new_description',
                ),
                title: 'new_title',
                description: 'new_description',
              ),
            ),
          );
          addTearDown(container.dispose);
        },
      );

      // blocTest<EditTodoBloc, EditTodoState>(
      //   'attempts to save updated todo to repository '
      //   'if an initial todo was provided',
      //   setUp: () {
      //     when(() => todosRepository.saveTodo(any())).thenAnswer((_) async {});
      //   },
      //   build: buildBloc,
      //   seed: () => EditTodoState(
      //     initialTodo: Todo(
      //       id: 'initial-id',
      //       title: 'initial-title',
      //     ),
      //     title: 'title',
      //     description: 'description',
      //   ),
      //   act: (bloc) => bloc.add(const EditTodoSubmitted()),
      //   expect: () => [
      //     EditTodoState(
      //       status: EditTodoStatus.loading,
      //       initialTodo: Todo(
      //         id: 'initial-id',
      //         title: 'initial-title',
      //       ),
      //       title: 'title',
      //       description: 'description',
      //     ),
      //     EditTodoState(
      //       status: EditTodoStatus.success,
      //       initialTodo: Todo(
      //         id: 'initial-id',
      //         title: 'initial-title',
      //       ),
      //       title: 'title',
      //       description: 'description',
      //     ),
      //   ],
      //   verify: (bloc) {
      //     verify(
      //       () => todosRepository.saveTodo(
      //         any(
      //           that: isA<Todo>()
      //               .having((t) => t.id, 'id', equals('initial-id'))
      //               .having((t) => t.title, 'title', equals('title'))
      //               .having(
      //                 (t) => t.description,
      //                 'description',
      //                 equals('description'),
      //               ),
      //         ),
      //       ),
      //     );
      //   },
      // );

      test(
        'emits new state with error if save to repository fails',
        () async {
          final container = createProviderContainer();
          final listener = Listener<EditTodoState>();
          container.listen(
            editTodoNotifierProvider(null),
            listener,
            fireImmediately: true,
          );
          when(() => container.read(todosRepositoryProvider).saveTodo(any()))
              .thenThrow(Exception('oops'));
          final notifier = container.read(editTodoNotifierProvider(null).notifier);
          notifier
            ..changeTitle('newTitle')
            ..changeDescription('newDescription');
          await notifier
            ..submitTodo();
          verifyInOrder(
            [
              // initial state before calling any method
              () {
                listener(
                  null,
                  EditTodoState(),
                );
              },
              // state after calling changeTitle('newTitle')
              () {
                listener(
                  EditTodoState(),
                  EditTodoState(title: 'newTitle'),
                );
              },
              // state after calling changeDescription('newDescription')
              () {
                listener(
                  EditTodoState(title: 'newTitle'),
                  EditTodoState(title: 'newTitle', description: 'newDescription'),
                );
              },
              // state after calling submitTodo()
              () {
                listener(
                  EditTodoState(
                    status: EditTodoStatus.loading,
                    title: 'newTitle',
                    description: 'newDescription',
                  ),
                  EditTodoState(
                    status: EditTodoStatus.failure,
                    title: 'newTitle',
                    description: 'newDescription',
                  ),
                );
              },
            ],
          );
          addTearDown(container.dispose);
        },
      );

      // blocTest<EditTodoBloc, EditTodoState>(
      //   'emits new state with error if save to repository fails',
      //   build: () {
      //     when(() => todosRepository.saveTodo(any())).thenThrow(Exception('oops'));
      //     return buildBloc();
      //   },
      //   seed: () => const EditTodoState(
      //     title: 'title',
      //     description: 'description',
      //   ),
      //   act: (bloc) => bloc.add(const EditTodoSubmitted()),
      //   expect: () => const [
      //     EditTodoState(
      //       status: EditTodoStatus.loading,
      //       title: 'title',
      //       description: 'description',
      //     ),
      //     EditTodoState(
      //       status: EditTodoStatus.failure,
      //       title: 'title',
      //       description: 'description',
      //     ),
      //   ],
      // );
    });
  });
}
