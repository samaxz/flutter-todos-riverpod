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

// TODO override this
// final overrides = [
//   todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
//   // editTodoNotifierProvider(initialTodo: mockTodo).overrideWith(() => mockEditTodoNotifier),
//   editTodoNotifierProvider().overrideWith(() => mockEditTodoNotifier),
//   // editTodoNotifierProvider(initialTodo: mockTodo).overrideWith(() => someMock),
// ];

void main() {
  final mockTodo = Todo(
    id: '1',
    title: 'title 1',
    description: 'description 1',
  );

  // this is wrong, cause it makes the notifiers override the same initialValue, thus throwing
  // exception
  // TODO remove this
  // final mockEditTodoNotifier = MockEditTodoNotifier();
  // final someMock = SomeMock();

  ProviderContainer createProviderContainer({
    required MockTodosRepository mockTodosRepository,
    // MockEditTodoNotifier? mockEditTodoNotifier,
    EditTodoNotifier? mockEditTodoNotifier,
    Todo? initialTodo,
    bool shouldOverrideNotifier = true,
  }) {
    final container = ProviderContainer(
      overrides: [
        // todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
        todosRepositoryProvider.overrideWithValue(mockTodosRepository),
        // editTodoNotifierProvider(initialTodo: mockTodo).overrideWith(() => mockEditTodoNotifier),
        // editTodoNotifierProvider().overrideWith(() => mockEditTodoNotifier),
        // editTodoNotifierProvider().overrideWith(() => MockEditTodoNotifier()),
        if (shouldOverrideNotifier)
          editTodoNotifierProvider(initialTodo: initialTodo).overrideWith(
            () => mockEditTodoNotifier ?? MockEditTodoNotifier.new(),
          ),
        // editTodoNotifierProvider(initialTodo: mockTodo).overrideWith(() => someMock),
      ],
      // overrides: overrides,
    );
    return container;
  }

  late MockNavigator navigator;

  setUp(() {
    navigator = MockNavigator();
    when(() => navigator.canPop()).thenReturn(false);
    when(() => navigator.push<void>(any())).thenAnswer((_) async {});

    final mockState = EditTodoState(
      initialTodo: mockTodo,
      title: mockTodo.title,
      description: mockTodo.description,
    );
    final mockTodosRepos = MockTodosRepository();
    final mockNotifier = MockEditTodoNotifier();
    final altMockNotifier = AltMockEditTodoNotifier();
    final container = createProviderContainer(
      mockTodosRepository: mockTodosRepos,
      initialTodo: mockTodo,
      // mockEditTodoNotifier: altMockNotifier,
      // TODO test this out
      mockEditTodoNotifier: mockNotifier,
    );
    container.read(editTodoNotifierProvider(initialTodo: mockTodo));

    // altMockNotifier.state = mockState;
    // when(() {
    //   debugPrint('altMockNotifier state inside edit_todo_page_test.dart: ${altMockNotifier.state}');
    //   return altMockNotifier.state;
    // }).thenReturn(mockState);

    mockNotifier.state = mockState;
    when(() {
      debugPrint('mockNotifier state inside edit_todo_page_test.dart: ${mockNotifier.state}');
      return mockNotifier.state;
    }).thenReturn(mockState);

    final notifier = container.read(editTodoNotifierProvider(initialTodo: mockTodo).notifier);
    notifier.state = mockState;
    when(() {
      debugPrint('notifier state inside edit_todo_page_test.dart: ${notifier.state}');
      return notifier.state;
    }).thenReturn(mockState);
    // debugPrint('notifier state inside edit_todo_page_test.dart: ${notifier.state}');

    final listener = Listener();
    container.listen(
      editTodoNotifierProvider(),
      listener,
      fireImmediately: true,
    );
    listener(null, mockState);

    // **************
    // final container = createProviderContainer();
    // container.read(editTodoNotifierProvider());

    // container.pump();

    // when(() {
    //   final container = createProviderContainer();
    //   container.read(editTodoNotifierProvider(initialTodo: mockTodo));
    //   // container
    //   //     .read(editTodoNotifierProvider(initialTodo: mockTodo).notifier)
    //   //     .build(initialTodo: mockTodo);
    //   // container.pump();
    //   debugPrint('mock state inside test: ${mockState}');
    //   // this isn't working for some reason
    //   mockEditTodoNotifier.state = mockState;
    //   mockEditTodoNotifier.setNewState(mockState);
    //
    //   // container.read(someMockProvider);
    //   // someMock.debugState = mockState;
    //   //
    //   // when(() => someMock.state).thenReturn(mockState);
    //
    //   container.pump();
    //
    //   debugPrint('state inside test: ${mockEditTodoNotifier.state}');
    //   return mockEditTodoNotifier.state;
    // }).thenReturn(mockState);

    // TODO either fix or remove this, cause it's not working at the moment
    // UPD i could use expect here
    // i can feel that this is wrong
    // when(() {
    //   final container = createProviderContainer();
    //   container.read(editTodoNotifierProvider(initialTodo: mockTodo));
    //   // container.updateOverrides(
    //   //   [
    //   //     todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
    //   //     editTodoNotifierProvider().overrideWith(() => mockEditTodoNotifier),
    //   //   ],
    //   // );
    //   // final huy = container.read(editTodoNotifierProvider().notifier).build();
    //   // var mock = container.read(editTodoNotifierProvider().notifier);
    //   // *******
    //   // UPD it's important to set the initial todo inside overrides
    //   // final mockNotifier = container.read(editTodoNotifierProvider(initialTodo: mockTodo).notifier);
    //   // mockNotifier.setNewState(mockTodo);
    //   // ******
    //   mockEditTodoNotifier.setNewState(mockTodo);
    //   // ******
    //   // mockNotifier.state = EditTodoState(
    //   //   initialTodo: mockTodo,
    //   //   title: mockTodo.title,
    //   //   description: mockTodo.description,
    //   // );
    //   // final setState = mockNotifier.setTodo(mockTodo);
    //   // debugPrint('${mockNotifier.state} state thru notifier inside edit_todo_page_test');
    //   // ********
    //   final mockState = container.read(editTodoNotifierProvider(initialTodo: mockTodo));
    //   debugPrint('${mockState} state inside edit_todo_page_test');
    //   // **********
    //   // without this, the state for the notifier won't be set
    //   // container.read(editTodoNotifierProvider());
    //   // // this doesn't set any state for some reason
    //   // mockEditTodoNotifier.state = EditTodoState(
    //   //   initialTodo: mockTodo,
    //   //   title: mockTodo.title,
    //   //   description: mockTodo.description,
    //   // );
    //   // debugPrint('${mockEditTodoNotifier.state} inside edit_todo_page_test');
    //   // ******
    //   // return container.read(editTodoNotifierProvider().notifier).setTodo(mockTodo);
    //   return mockEditTodoNotifier.state;
    //   // return setState;
    //   // return mockNotifier.build(initialTodo: mockTodo);
    //   // return mockNotifier.state;
    //   return mockState;
    // }).thenReturn(
    //   EditTodoState(
    //     initialTodo: mockTodo,
    //     title: mockTodo.title,
    //     description: mockTodo.description,
    //   ),
    //   // mockEditTodoNotifier.state,
    // );
    // **************
  });

  // tearDown(() => null)

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
        final initialTodo = Todo(title: 'title');
        final mockTodosRepos = MockTodosRepository();
        final container = createProviderContainer(
          mockTodosRepository: mockTodosRepos,
          initialTodo: initialTodo,
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
          listener,
          fireImmediately: true,
        );
        // container.read(editTodoNotifierProvider(initialTodo: initialTodo))
        verify(
          () => listener(
            const EditTodoState(),
            EditTodoState(
              initialTodo: Todo(title: 'title'),
            ),
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
        final mockTodosRepos = MockTodosRepository();
        final container = createProviderContainer(mockTodosRepository: mockTodosRepos);
        // when(() => editTodoBloc.state).thenReturn(
        when(() {
          return container.read(editTodoNotifierProvider().notifier).setTodo(Todo(title: ''));
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
        final container = createProviderContainer(mockTodosRepository: mockTodosRepos);
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
          final mockTodosRepos = MockTodosRepository();
          final mockEditTodoNotifier = MockEditTodoNotifier.new();
          // when(() => mockTodosRepos.saveTodo(Todo(title: ''))).thenAnswer((_) => Future.value());
          final container = createProviderContainer(
            mockTodosRepository: mockTodosRepos,
            mockEditTodoNotifier: mockEditTodoNotifier,
            // shouldOverrideNotifier: false,
          );
          final listener = Listener();
          container.listen(
            editTodoNotifierProvider(),
            listener,
            fireImmediately: true,
          );
          verify(() => listener(null, const EditTodoState()));
          when(() => mockEditTodoNotifier.submitTodo()).thenAnswer((_) async {});
          // listener(
          //   null,
          //   EditTodoState(),
          // );
          // await notifier.submitTodo();
          await tester.pumpApp(buildSubject());
          await tester.tap(find.byType(FloatingActionButton));
          // final notifier = container.read(editTodoNotifierProvider().notifier);
          await container.read(editTodoNotifierProvider().notifier).submitTodo();

          // verify(() => editTodoBloc.add(const EditTodoSubmitted())).called(1);
          // verify(notifier.submitTodo).called(1);
          verify(
            () {
              // final provider = container.read(todosRepositoryProvider);
              // return provider.saveTodo(Todo(title: ''));
              // this is supposed to be working, but it's not for some reason
              mockTodosRepos.saveTodo(Todo(title: ''));
            },
          ).called(1);
        },
      );
    });
  });
}
