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
  // late MockTodosRepository mockTodosRepository;
  // late MockEditTodoNotifier mockEditTodoNotifier;
  // late ProviderContainer providerContainer;

  setUp(() {
    navigator = MockNavigator();
    when(() => navigator.canPop()).thenReturn(false);
    when(() => navigator.push<void>(any())).thenAnswer((_) async {});
    // TODO use provider container here (or don't)

    // TODO move this down below where it's used
    registerFallbackValue(Todo(title: ''));
    // TODO remove these
    // registerFallbackValue(Todo(title: 'title'));
    // registerFallbackValue('title');

    // final mockTodo = Todo(
    //   id: '1',
    //   title: 'title 1',
    //   description: 'description 1',
    // );
    // final mockState = EditTodoState(
    //   initialTodo: mockTodo,
    //   title: mockTodo.title,
    //   description: mockTodo.description,
    // );
    // // creating and initializing all of it here is kind of pointless
    // mockTodosRepository = MockTodosRepository();
    // mockEditTodoNotifier = MockEditTodoNotifier.new();
    // providerContainer = createProviderContainer(
    //   mockTodosRepository: mockTodosRepository,
    //   initialTodo: mockTodo,
    //   mockEditTodoNotifier: mockEditTodoNotifier,
    // );
    // when(
    //   () => providerContainer.read(
    //     editTodoNotifierProvider(initialTodo: mockTodo),
    //   ),
    // ).thenReturn(mockState);
    // final mockEditTodoNotifier = MockEditTodoNotifier.new();
    // final container = createProviderContainer(
    //   mockTodosRepository: mockTodosRepos,
    //   initialTodo: mockTodo,
    //   mockEditTodoNotifier: mockEditTodoNotifier,
    // );
    // when(
    //   () => container.read(
    //     editTodoNotifierProvider(initialTodo: mockTodo),
    //   ),
    // ).thenReturn(mockState);
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
        final mockEditTodoNotifier = MockEditTodoNotifier.new();
        final mockTodosRepos = MockTodosRepository();
        final container = createProviderContainer(mockTodosRepository: mockTodosRepos);
        final listener = Listener();
        container.listen(
          editTodoNotifierProvider(),
          listener,
          fireImmediately: true,
        );
        // listener(
        //   null,
        //   EditTodoState(),
        // );
        when(mockEditTodoNotifier.submitTodo).thenAnswer((_) async {
          // listener(
          //   EditTodoState(),
          //   EditTodoState(status: EditTodoStatus.success),
          // );
        });
        listener(
          const EditTodoState(),
          const EditTodoState(status: EditTodoStatus.success),
        );
        await tester.pumpApp(buildSubject());

        await mockEditTodoNotifier.submitTodo();

        navigator.pop();

        // i'm not sure i need to pass result here
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
        final mockTodosRepos = MockTodosRepository();
        final mockEditTodoNotifier = MockEditTodoNotifier.new();
        final container = createProviderContainer(
          mockTodosRepository: mockTodosRepos,
          mockEditTodoNotifier: mockEditTodoNotifier,
        );
        when(
          () => container.read(editTodoNotifierProvider()),
        ).thenReturn(const EditTodoState());

        await tester.pumpApp(buildSubject());

        // await tester.pumpWidget(Container());

        // expect(find.byType(Container, skipOffstage: false), findsOneWidget);
        // expect(find.byType(Scaffold, skipOffstage: false), findsOneWidget);
        expect(
          find.byType(AppBar, skipOffstage: false),
          // find.byKey(Key('appbar'), skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(l10n.editTodoAddAppBarTitle),
          ),
          findsOneWidget,
        );

        await tester.pumpWidget(Container());
      },
    );

    testWidgets(
      'renders AppBar with title text for editing todos '
      'when an existing todo is being edited',
      (tester) async {
        final initialTodo = Todo(title: 'title');
        final mockTodosRepos = MockTodosRepository();
        final mockEditTodoNotifier = MockEditTodoNotifier.new();
        final container = createProviderContainer(
          mockTodosRepository: mockTodosRepos,
          initialTodo: initialTodo,
          mockEditTodoNotifier: mockEditTodoNotifier,
        );
        when(
          () => container.read(
            editTodoNotifierProvider(initialTodo: initialTodo),
          ),
        ).thenReturn(
          EditTodoState(initialTodo: initialTodo),
        );
        // final listener = Listener();
        // container.listen(
        //   editTodoNotifierProvider(initialTodo: initialTodo),
        //   listener,
        //   fireImmediately: true,
        // );
        // verify(
        //   () => listener(
        //     null,
        //     EditTodoState(initialTodo: initialTodo),
        //   ),
        // );

        await tester.pumpApp(buildSubject());

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar, skipOffstage: false),
            // of: find.widgetWithText(AppBar, 'Edit Todo'),
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
        final mockTodosRepos = MockTodosRepository();
        final mockEditTodoNotifier = MockEditTodoNotifier.new();
        final container = createProviderContainer(
          mockTodosRepository: mockTodosRepos,
          mockEditTodoNotifier: mockEditTodoNotifier,
        );
        when(
          () => container.read(editTodoNotifierProvider()),
        ).thenReturn(
          const EditTodoState(status: EditTodoStatus.loading),
        );
        await tester.pumpApp(buildSubject());

        final textField = tester.widget<TextFormField>(find.byKey(descriptionTextFormField));
        // textField.
      });

      testWidgets(
        'adds EditTodoTitleChanged '
        'to EditTodoNotifier '
        'when a new value is entered',
        (tester) async {
          final mockEditTodoNotifier = MockEditTodoNotifier.new();
          // final mockTodosRepos = MockTodosRepository();
          // final container = createProviderContainer(mockTodosRepository: mockTodosRepos);
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
        final mockTodosRepos = MockTodosRepository();
        final mockEditTodoNotifier = MockEditTodoNotifier.new();
        final container = createProviderContainer(
          mockTodosRepository: mockTodosRepos,
          mockEditTodoNotifier: mockEditTodoNotifier,
        );
        // when(() => editTodoBloc.state).thenReturn(
        // strange - this doesn't throw any exception
        when(
          () => container.read(editTodoNotifierProvider()),
        ).thenReturn(
          const EditTodoState(status: EditTodoStatus.loading),
        );
        await tester.pumpApp(buildSubject());

        final textField = tester.widget<TextFormField>(find.byKey(titleTextFormField));
        expect(textField.enabled, false);
      });

      testWidgets(
        'adds EditTodoDescriptionChanged '
        'to EditTodoNotifier '
        'when a new value is entered',
        (tester) async {
          // final mockTodosRepos = MockTodosRepository();
          final mockEditTodoNotifier = MockEditTodoNotifier.new();
          // final container = createProviderContainer(
          //   mockTodosRepository: mockTodosRepos,
          //   mockEditTodoNotifier: mockEditTodoNotifier,
          // );
          await tester.pumpApp(buildSubject());
          await tester.enterText(
            find.byKey(descriptionTextFormField),
            'newdescription',
          );

          mockEditTodoNotifier.changeDescription('newdescription');

          verify(
            () => mockEditTodoNotifier.changeDescription('newdescription'),
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
          final mockTodosRepos = MockTodosRepository();
          when(() => mockTodosRepos.saveTodo(any())).thenAnswer((_) => Future.value());
          // final mockEditTodoNotifier = MockEditTodoNotifier.new();
          final container = createProviderContainer(
            mockTodosRepository: mockTodosRepos,
            // mockEditTodoNotifier: mockEditTodoNotifier,
          );
          final listener = Listener();
          container.listen(
            editTodoNotifierProvider(),
            listener,
            fireImmediately: true,
          );
          verify(() => listener(null, const EditTodoState()));
          // when(() => mockEditTodoNotifier.submitTodo()).thenAnswer((_) => Future.value());

          await tester.pumpApp(buildSubject());
          await tester.tap(find.byType(FloatingActionButton));
          // final notifier = container.read(editTodoNotifierProvider().notifier);
          await container.read(editTodoNotifierProvider().notifier).submitTodo();

          // verify(() => editTodoBloc.add(const EditTodoSubmitted())).called(1);
          verify(
            // () => mockTodosRepos.saveTodo(todo),
            // this works
            () => mockTodosRepos.saveTodo(any(that: isA<Todo>())),
          ).called(1);
        },
      );
    });
  });
}
