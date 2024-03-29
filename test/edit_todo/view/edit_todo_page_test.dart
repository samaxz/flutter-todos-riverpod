import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
import 'package:flutter_todos/edit_todo/notifier/edit_todo_notifier.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

class Listener<EditTodoState> extends Mock {
  void call(EditTodoState? previous, EditTodoState next);
}

void main() {
  ProviderContainer createProviderContainer({
    required MockTodosRepository mockTodosRepository,
    Todo? initialTodo,
    // optionally mock notifier
    EditTodoNotifier? mockEditTodoNotifier,
  }) {
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(mockTodosRepository),
        if (mockEditTodoNotifier != null)
          editTodoNotifierProvider(initialTodo: initialTodo).overrideWith(
            () => mockEditTodoNotifier,
          ),
      ],
    );
    return container;
  }

  late MockNavigator navigator;
  late MockTodosRepository mockTodosRepository;
  late MockEditTodoNotifier mockEditTodoNotifier;

  setUp(() {
    navigator = MockNavigator();
    when(() => navigator.canPop()).thenReturn(false);
    when(() => navigator.push<void>(any())).thenAnswer((_) async {});

    mockTodosRepository = MockTodosRepository();
    mockEditTodoNotifier = MockEditTodoNotifier.new();

    // TODO move this down below where it's used
    registerFallbackValue(Todo(title: ''));
  });

  // TODO probably add initial todo here in the future
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
        final initialTodo = Todo(id: 'initial-id', title: 'initial');
        await tester.pumpRoute(
          EditTodoPage.route(initialTodo: initialTodo),
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

    // TODO probably change this in the future
    testWidgets(
      'pops when a todo was saved successfully',
      (tester) async {
        await tester.pumpApp(buildSubject());

        // in order for this to work, mock methods should be overridden
        await mockEditTodoNotifier.submitTodo();
        // since it's a real method, the notifier shouldn't be overridden
        // this throws ```Pending timers:``` exception
        // await container.read(editTodoNotifierProvider().notifier).submitTodo();

        navigator.pop();

        // i'm not sure i need to pass result here
        verify(() => navigator.pop<Object?>(any<dynamic>())).called(1);
      },
    );
  });

  group('EditTodoView', () {
    const titleTextFormField = Key('editTodoView_title_textFormField');
    const descriptionTextFormField = Key('editTodoView_description_textFormField');

    Widget buildSubject({Todo? initialTodo}) {
      return MockNavigatorProvider(
        navigator: navigator,
        child: EditTodoPage(initialTodo: initialTodo),
      );
    }

    testWidgets(
      'renders AppBar with title text for new todos '
      'when a new todo is being created',
      (tester) async {
        await tester.pumpApp(buildSubject());

        expect(
          find.byType(AppBar, skipOffstage: false),
          findsOneWidget,
        );
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
        final initialTodo = Todo(title: 'title');

        await tester.pumpApp(
          buildSubject(initialTodo: initialTodo),
          initialTodo: initialTodo,
          mockTodosRepository: mockTodosRepository,
          mockEditTodoNotifier: mockEditTodoNotifier,
        );

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar, skipOffstage: false),
            matching: find.text(l10n.editTodoEditAppBarTitle),
            skipOffstage: false,
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
        await tester.pumpApp(
          buildSubject(),
          mockEditTodoNotifier: mockEditTodoNotifier,
        );

        final textField = tester.widget<TextFormField>(find.byKey(descriptionTextFormField));
        expect(textField.enabled, false);
      });

      testWidgets(
        'adds EditTodoTitleChanged '
        'to EditTodoNotifier '
        'when a new value is entered',
        (tester) async {
          await tester.pumpApp(buildSubject());
          await tester.enterText(
            find.byKey(titleTextFormField),
            'newtitle',
          );

          mockEditTodoNotifier.changeTitle('newtitle');

          verify(
            () => mockEditTodoNotifier.changeTitle('newtitle'),
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
        await tester.pumpApp(
          buildSubject(),
          mockTodosRepository: mockTodosRepository,
          mockEditTodoNotifier: mockEditTodoNotifier,
        );

        final textField = tester.widget<TextFormField>(find.byKey(titleTextFormField));
        // it's enabled, once the edit todo notifier's status is not loading
        expect(textField.enabled, false);
      });

      testWidgets(
        'adds EditTodoDescriptionChanged '
        'to EditTodoNotifier '
        'when a new value is entered',
        (tester) async {
          await tester.pumpApp(buildSubject());
          await tester.enterText(
            find.byKey(descriptionTextFormField),
            'newDescription',
          );

          mockEditTodoNotifier.changeDescription('newDescription');

          verify(
            () => mockEditTodoNotifier.changeDescription('newDescription'),
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
        'to EditTodoNotifier '
        'when tapped',
        (tester) async {
          when(() => mockTodosRepository.saveTodo(any())).thenAnswer((_) => Future.value());
          final container = createProviderContainer(mockTodosRepository: mockTodosRepository);
          final listener = Listener();
          container.listen(
            editTodoNotifierProvider(),
            listener,
            fireImmediately: true,
          );

          verify(() => listener(null, const EditTodoState()));

          await tester.pumpApp(buildSubject());
          await tester.tap(find.byType(FloatingActionButton));
          await container.read(editTodoNotifierProvider().notifier).submitTodo();
          addTearDown(() => container.dispose());

          verify(
            () => mockTodosRepository.saveTodo(any(that: isA<Todo>())),
          ).called(1);
        },
      );
    });
  });
}
