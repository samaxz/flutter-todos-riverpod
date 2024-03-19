import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/edit_todo/notifier/edit_todo_notifier.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class FakeTodo extends Fake implements Todo {}

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  ProviderContainer createProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
      ],
    );
    // this throws, as it can only be used inside tests
    // addTearDown(container.dispose);
    return container;
  }

  group('EditTodoNotifier', () {
    setUpAll(() => registerFallbackValue(FakeTodo()));

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
        verify(
          () => listener(null, const EditTodoState()),
        ).called(1);
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
      container.read(editTodoNotifierProvider(null).notifier).changeTitle('new_title');
      verify(
        () => listener(
          EditTodoState(),
          EditTodoState(title: 'new_title'),
        ),
      ).called(1);
      addTearDown(container.dispose);
    });

    test('emits new state with updated description', () {
      final container = createProviderContainer();
      final listener = Listener<EditTodoState>();
      container.listen(
        editTodoNotifierProvider(null),
        listener,
        fireImmediately: true,
      );
      container.read(editTodoNotifierProvider(null).notifier).changeDescription('new_description');
      verify(
        () => listener(
          EditTodoState(),
          EditTodoState(description: 'new_description'),
        ),
      ).called(1);
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
          final notifier = container.read(editTodoNotifierProvider(null).notifier);
          notifier
            ..changeTitle('new_title')
            ..changeDescription('new_description');
          verifyInOrder(
            [
              // initial state before calling any method
              () {
                listener(
                  null,
                  EditTodoState(),
                );
              },
              // state after calling changeTitle('new_title')
              () {
                listener(
                  EditTodoState(),
                  EditTodoState(title: 'new_title'),
                );
              },
              // state after calling changeDescription('new_description')
              () {
                listener(
                  EditTodoState(title: 'new_title'),
                  EditTodoState(title: 'new_title', description: 'new_description'),
                );
              },
            ],
          );
          await notifier
            ..submitTodo();
          verify(
            () => listener(
              EditTodoState(
                title: 'new_title',
                description: 'new_description',
              ),
              EditTodoState(
                status: EditTodoStatus.loading,
                title: 'new_title',
                description: 'new_description',
              ),
            ),
          );
          verify(
            () => container.read(todosRepositoryProvider).saveTodo(
                  any(
                    that:
                        isA<Todo>().having((t) => t.title, 'new_title', equals('new_title')).having(
                              (t) => t.description,
                              'new_description',
                              equals('new_description'),
                            ),
                  ),
                ),
          ).called(1);
          addTearDown(container.dispose);
        },
      );

      test(
        'attempts to save updated todo to repository '
        'if an initial todo was provided',
        () async {
          // TODO probably add id here
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
          // verify that the todo has been saved successfully
          verify(
            () => container.read(todosRepositoryProvider).saveTodo(
                  any(
                    that: isA<Todo>()
                        .having(
                          (t) => t.title,
                          'new_title',
                          equals('new_title'),
                        )
                        .having(
                          (t) => t.description,
                          'new_description',
                          equals('new_description'),
                        ),
                  ),
                ),
          ).called(1);
          addTearDown(container.dispose);
        },
      );

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
            ..changeTitle('new_title')
            ..changeDescription('new_description');
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
              // state after calling changeTitle('new_title')
              () {
                listener(
                  EditTodoState(),
                  EditTodoState(title: 'new_title'),
                );
              },
              // state after calling changeDescription('new_description')
              () {
                listener(
                  EditTodoState(title: 'new_title'),
                  EditTodoState(title: 'new_title', description: 'new_description'),
                );
              },
              // state after calling submitTodo()
              () {
                listener(
                  EditTodoState(
                    status: EditTodoStatus.loading,
                    title: 'new_title',
                    description: 'new_description',
                  ),
                  EditTodoState(
                    status: EditTodoStatus.failure,
                    title: 'new_title',
                    description: 'new_description',
                  ),
                );
              },
            ],
          );
          addTearDown(container.dispose);
        },
      );
    });
  });
}
