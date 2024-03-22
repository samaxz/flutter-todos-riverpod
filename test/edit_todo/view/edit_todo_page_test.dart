import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
import 'package:flutter_todos/edit_todo/notifier/edit_todo_notifier.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  final mockTodo = Todo(
    id: '1',
    title: 'title 1',
    description: 'description 1',
  );

  ProviderContainer createProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
        editTodoNotifierProvider().overrideWith(() => MockEditTodoNotifier()),
      ],
    );
    return container;
  }

  late MockNavigator navigator;

  setUp(() {
    navigator = MockNavigator();
    when(() => navigator.canPop()).thenReturn(false);
    when(() => navigator.push<void>(any())).thenAnswer((_) async {});

    when(() {
      final container = createProviderContainer();
      return container.read(editTodoNotifierProvider().notifier).setTodo(mockTodo);
    }).thenReturn(
      EditTodoState(
        initialTodo: mockTodo,
        title: mockTodo.title,
        description: mockTodo.description,
      ),
    );
  });

  group('EditTodoPage', () {
    Widget buildSubject() {
      return MockNavigatorProvider(
        navigator: navigator,
        child: const EditTodoPage(),
      );
    }

    group('route', () {
      testWidgets('renders EditTodoPage', (tester) async {
        await tester.pumpRoute(EditTodoPage.route());
        expect(find.byType(EditTodoPage), findsOneWidget);
      });

      testWidgets('supports providing an initial todo', (tester) async {
        await tester.pumpRoute(
          EditTodoPage.route(
            initialTodo: Todo(id: 'initial-id', title: 'initial'),
          ),
        );
        expect(find.byType(EditTodoPage), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (w) => w is EditableText && w.controller.text == 'initial',
          ),
          findsOneWidget,
        );
      });
    });

    testWidgets('renders EditTodoView', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(find.byType(EditTodoPage), findsOneWidget);
    });

    testWidgets(
      'pops when a todo was saved successfully',
      (tester) async {
        // whenListen<EditTodoState>(
        //   editTodoBloc,
        //   Stream.fromIterable(const [
        //     EditTodoState(),
        //     EditTodoState(status: EditTodoStatus.success),
        //   ]),
        // );
        final container = createProviderContainer();
        final listener = Listener<EditTodoState>();
        container.listen(
          editTodoNotifierProvider(),
          listener,
          fireImmediately: true,
        );
        listener(
          null,
          EditTodoState(),
        );
        await tester.pumpApp(buildSubject());

        verify(() => navigator.pop<Object?>(any<dynamic>())).called(1);
      },
    );
  });

  group('EditTodoView', () {
    const titleTextFormField = Key('editTodoView_title_textFormField');
    const descriptionTextFormField = Key('editTodoView_description_textFormField');

    Widget buildSubject() {
      return MockNavigatorProvider(
        navigator: navigator,
        child: const EditTodoPage(),
      );
    }

    testWidgets(
      'renders AppBar with title text for new todos '
      'when a new todo is being created',
      (tester) async {
        final container = createProviderContainer();
        // when(() => editTodoBloc.state).thenReturn(const EditTodoState());
        when(() {
          return container
              .read(editTodoNotifierProvider().notifier)
              .setTodo(Todo(title: ''));
        }).thenReturn(const EditTodoState());
        await tester.pumpApp(buildSubject());

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(l10n.editTodoAddAppBarTitle),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders AppBar with title text for editing todos '
      'when an existing todo is being edited',
      (tester) async {
        final container = createProviderContainer();
        // when(() => editTodoBloc.state).thenReturn(
        when(() {
          return container
              .read(editTodoNotifierProvider().notifier)
              .setTodo(Todo(title: 'title'));
        }).thenReturn(
          EditTodoState(
            initialTodo: Todo(title: 'title'),
          ),
        );
        await tester.pumpApp(buildSubject());

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(l10n.editTodoEditAppBarTitle),
          ),
          findsOneWidget,
        );
      },
    );

    group('title text form field', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.byKey(titleTextFormField), findsOneWidget);
      });

      testWidgets('is disabled when loading', (tester) async {
        final container = createProviderContainer();
        // when(() => editTodoBloc.state).thenReturn(
        when(() {
          return container
              .read(editTodoNotifierProvider().notifier)
              .setTodo(Todo(title: ''));
        }).thenReturn(
          const EditTodoState(status: EditTodoStatus.loading),
        );
        await tester.pumpApp(buildSubject());

        final textField =
            tester.widget<TextFormField>(find.byKey(descriptionTextFormField));
        expect(textField.enabled, false);
      });

      testWidgets(
        'adds EditTodoTitleChanged '
        'to EditTodoBloc '
        'when a new value is entered',
        (tester) async {
          final container = createProviderContainer();
          await tester.pumpApp(buildSubject());
          await tester.enterText(
            find.byKey(titleTextFormField),
            'newtitle',
          );

          verify(
            // () => editTodoBloc.add(const EditTodoTitleChanged('newtitle')),
            () => container
                .read(editTodoNotifierProvider().notifier)
                .changeTitle('newtitle'),
          ).called(1);
        },
      );
    });

    group('description text form field', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.byKey(descriptionTextFormField), findsOneWidget);
      });

      testWidgets('is disabled when loading', (tester) async {
        final container = createProviderContainer();
        // when(() => editTodoBloc.state).thenReturn(
        when(() {
          return container.read(editTodoNotifierProvider());
        }).thenReturn(
          const EditTodoState(status: EditTodoStatus.loading),
        );
        await tester.pumpApp(buildSubject());

        final textField = tester.widget<TextFormField>(find.byKey(titleTextFormField));
        expect(textField.enabled, false);
      });

      testWidgets(
        'adds EditTodoDescriptionChanged '
        'to EditTodoBloc '
        'when a new value is entered',
        (tester) async {
          final container = createProviderContainer();
          await tester.pumpApp(buildSubject());
          await tester.enterText(
            find.byKey(descriptionTextFormField),
            'newdescription',
          );

          verify(
            // () => editTodoBloc.add(const EditTodoDescriptionChanged('newdescription')),
            () => container
                .read(editTodoNotifierProvider().notifier)
                .changeDescription('newdescription'),
          ).called(1);
        },
      );
    });

    group('save fab', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(
          find.descendant(
            of: find.byType(FloatingActionButton),
            matching: find.byTooltip(l10n.editTodoSaveButtonTooltip),
          ),
          findsOneWidget,
        );
      });

      testWidgets(
        'adds EditTodoSubmitted '
        'to EditTodoBloc '
        'when tapped',
        (tester) async {
          final container = createProviderContainer();
          await tester.pumpApp(buildSubject());
          await tester.tap(find.byType(FloatingActionButton));

          // verify(() => editTodoBloc.add(const EditTodoSubmitted())).called(1);
          verify(container.read(editTodoNotifierProvider().notifier).submitTodo)
              .called(1);
        },
      );
    });
  });
}
