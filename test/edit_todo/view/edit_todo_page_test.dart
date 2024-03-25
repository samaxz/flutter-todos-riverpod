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
    // TODO remove this and pass MockEditTodoNotifier.new() inside of here
    EditTodoNotifier? mockEditTodoNotifier,
    Todo? initialTodo,
    // i can remove this
    // bool shouldOverrideNotifier = true,
  }) {
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(mockTodosRepository),
        // if (shouldOverrideNotifier)
        if (mockEditTodoNotifier != null)
          editTodoNotifierProvider(initialTodo: initialTodo).overrideWith(
            () => mockEditTodoNotifier,
          ),
      ],
    );
    return container;
  }

  late MockNavigator navigator;

  setUp(() {
    navigator = MockNavigator();
    when(() => navigator.canPop()).thenReturn(false);
    when(() => navigator.push<void>(any())).thenAnswer((_) async {});
    // TODO use provider container here (or don't)

    registerFallbackValue(Todo(title: ''));
    registerFallbackValue(Todo(title: 'title'));
    registerFallbackValue('title');

    final mockTodo = Todo(
      id: '1',
      title: 'title 1',
      description: 'description 1',
    );

    final mockState = EditTodoState(
      initialTodo: mockTodo,
      title: mockTodo.title,
      description: mockTodo.description,
    );
    final mockTodosRepos = MockTodosRepository();
    // this works
    when(() => mockTodosRepos.saveTodo(mockTodo)).thenAnswer((_) => Future.value());

    final mockEditTodoNotifier = MockEditTodoNotifier.new();
    // final altMockNotifier = AltMockEditTodoNotifier();
    final container = createProviderContainer(
      mockTodosRepository: mockTodosRepos,
      initialTodo: mockTodo,
      // mockEditTodoNotifier: altMockNotifier,
      // TODO test this out
      mockEditTodoNotifier: mockEditTodoNotifier,
    );
    // when(() {
    //   return container.read(editTodoNotifierProvider());
    // }).thenReturn(
    //   const EditTodoState(status: EditTodoStatus.loading),
    // );
    when(
      () => container.read(
        editTodoNotifierProvider(initialTodo: mockTodo),
      ),
    ).thenReturn(mockState);
    // container.read(editTodoNotifierProvider(initialTodo: mockTodo));

    // altMockNotifier.state = mockState;
    // when(() {
    //   debugPrint('altMockNotifier state inside edit_todo_page_test.dart: ${altMockNotifier.state}');
    //   return altMockNotifier.state;
    // }).thenReturn(mockState);

    // mockNotifier.state = mockState;
    // when(() {
    //   debugPrint('mockNotifier state inside edit_todo_page_test.dart: ${mockNotifier.state}');
    //   return mockNotifier.state;
    // }).thenReturn(mockState);

    final notifier = container.read(editTodoNotifierProvider(initialTodo: mockTodo).notifier);
    notifier.state = mockState;
    // notifier.state = mockState;
    // when(() {
    //   debugPrint('notifier state inside edit_todo_page_test.dart: ${notifier.state}');
    //   return notifier.state;
    // }).thenReturn(mockState);

    // final listener = Listener();
    // container.listen(
    //   editTodoNotifierProvider(),
    //   listener,
    //   fireImmediately: true,
    // );
    //
    // verify(
    //   // () => listener(null, mockState),
    //   () => listener(
    //     null,
    //     const EditTodoState(),
    //   ),
    // );

    // notifier.submitTodo();
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
        // final container = createProviderContainer();
        // container.updateOverrides(
        //   [
        //     todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
        //     editTodoNotifierProvider().overrideWith(() => MockEditTodoNotifier()),
        //   ],
        // );
        final initialTodo = Todo(id: 'initial-id', title: 'initial');
        await tester.pumpRoute(
          EditTodoPage.route(initialTodo: initialTodo),
          initialTodo: initialTodo,
          // overrides: [
          //   todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
          //   editTodoNotifierProvider().overrideWith(() => MockEditTodoNotifier()),
          // ],
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
        final mockTodosRepos = MockTodosRepository();
        final container = createProviderContainer(mockTodosRepository: mockTodosRepos);
        final listener = Listener();
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
        final container = createProviderContainer(mockTodosRepository: mockTodosRepos);
        // when(() => editTodoBloc.state).thenReturn(const EditTodoState());
        // when(() {
        //   // return container.read(editTodoNotifierProvider().notifier).setTodo(Todo(title: ''));
        //   return container.read(editTodoNotifierProvider().notifier).state;
        // }).thenReturn(const EditTodoState());
        // final huy = container.read(editTodoNotifierProvider());
        // this throws ```The following assertion was thrown running a test:
        // A Timer is still pending even after the widget tree was disposed.```
        // expect(
        //   container.read(editTodoNotifierProvider()),
        //   const EditTodoState(),
        // );
        final listener = Listener();
        container.listen(
          editTodoNotifierProvider(),
          listener,
          fireImmediately: true,
        );
        verify(
          () => listener(
            null,
            const EditTodoState(),
          ),
        );

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
        // TODO remove this
        // registerFallbackValue(Todo(title: 'title'));

        final initialTodo = Todo(title: 'title');
        // final initialTodo = Todo(title: any(named: 'title'));
        final mockTodosRepos = MockTodosRepository();
        final container = createProviderContainer(
          mockTodosRepository: mockTodosRepos,
          initialTodo: initialTodo,
          // initialTodo: any(named: 'title'),
        );
        // when(() => editTodoBloc.state).thenReturn(
        // when(() {
        //   return container.read(editTodoNotifierProvider().notifier).setTodo(Todo(title: 'title'));
        // }).thenReturn(
        //   EditTodoState(
        //     initialTodo: Todo(title: 'title'),
        //   ),
        // );
        final listener = Listener();
        container.listen(
          editTodoNotifierProvider(initialTodo: initialTodo),
          // editTodoNotifierProvider(initialTodo: any()),
          listener,
          fireImmediately: true,
        );
        // container.read(editTodoNotifierProvider(initialTodo: initialTodo))
        verify(
          () => listener(
            // const EditTodoState(),
            null,
            EditTodoState(
              // initialTodo: Todo(title: 'title'),
              // initialTodo: initialTodo,
              // initialTodo: any(that: isA<Todo>()),
              // initialTodo: any(
              //   that: isA<Todo>().having((todo) => todo.title, 'title', contains('title')),
              // ),
              // this works
              initialTodo: initialTodo,
              // initialTodo: any<Todo>(named: 'Todo(title: "title")'),
              // initialTodo: Todo(title: any<String>(named: 'title')),
              // initialTodo: any<Todo>(that: isA<Todo>().having((p0) => null, description, matcher)),
              // title: 'title',
            ),
          ),
        );

        await tester.pumpApp(buildSubject());

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            // of: find.widgetWithText(AppBar, 'Edit Todo'),
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
        final mockTodosRepos = MockTodosRepository();
        final mockEditTodoNotifier = MockEditTodoNotifier();
        final container = createProviderContainer(
          mockTodosRepository: mockTodosRepos,
          mockEditTodoNotifier: mockEditTodoNotifier,
        );
        // when(() => editTodoBloc.state).thenReturn(
        when(() {
          // return container.read(editTodoNotifierProvider().notifier).setTodo(Todo(title: ''));
          return container.read(editTodoNotifierProvider());
        }).thenReturn(
          const EditTodoState(status: EditTodoStatus.loading),
        );
        await tester.pumpApp(buildSubject());

        final textField = tester.widget<TextFormField>(find.byKey(descriptionTextFormField));
        expect(textField.enabled, false);
      });

      testWidgets(
        'adds EditTodoTitleChanged '
        'to EditTodoNotifier '
        'when a new value is entered',
        (tester) async {
          final mockTodosRepos = MockTodosRepository();
          final container = createProviderContainer(mockTodosRepository: mockTodosRepos);
          await tester.pumpApp(buildSubject());
          await tester.enterText(
            find.byKey(titleTextFormField),
            'newtitle',
          );

          verify(
            // () => editTodoBloc.add(const EditTodoTitleChanged('newtitle')),
            () => container.read(editTodoNotifierProvider().notifier).changeTitle('newtitle'),
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
        'to EditTodoNotifier '
        'when a new value is entered',
        (tester) async {
          final mockTodosRepos = MockTodosRepository();
          final container = createProviderContainer(mockTodosRepository: mockTodosRepos);
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
        'to EditTodoNotifier '
        'when tapped',
        (tester) async {
          // final todo = Todo(title: '');
          final mockTodosRepos = MockTodosRepository();
          // when(() => mockTodosRepos.saveTodo(todo)).thenAnswer((_) => Future.value());
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
