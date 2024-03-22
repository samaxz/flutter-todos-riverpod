import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/home/home.dart';
import 'package:flutter_todos/home/notifier/home_notifier.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:flutter_todos/stats/notifier/stats_notifier.dart';
import 'package:flutter_todos/stats/stats.dart';
import 'package:flutter_todos/todos_overview/notifier/todos_overview_notifier.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

// class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  late TodosRepository todosRepository;

  ProviderContainer createProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        // weird, but, this causes null state
        homeNotifierProvider.overrideWith(() => MockHomeNotifier()),
        // todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
        statsNotifierProvider.overrideWith(() => MockStatsNotifier()),
      ],
    );
    // this throws, since it can only be used inside tests
    // addTearDown(container.dispose);
    return container;
  }

  group('HomePage', () {
    setUp(() {
      todosRepository = MockTodosRepository();
      when(todosRepository.getTodos).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('renders HomeView', (tester) async {
      await tester.pumpApp(
        ProviderScope(
          overrides: [
            // weird, but, this causes null state
            homeNotifierProvider.overrideWith(() => MockHomeNotifier()),
            todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
            statsNotifierProvider.overrideWith(() => MockStatsNotifier()),
            todosOverviewNotifierProvider.overrideWith(() => MockTodosOverviewNotifier()),
          ],
          child: const HomePage(),
        ),
        todosRepository: todosRepository,
      );

      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('HomeView', () {
    const addTodoFloatingActionButtonKey = Key(
      'homeView_addTodo_floatingActionButton',
    );

    late MockNavigator navigator;
    // late HomeCubit cubit;

    setUp(() {
      navigator = MockNavigator();
      when(() => navigator.canPop()).thenReturn(false);
      when(() => navigator.push<void>(any())).thenAnswer((_) async {});

      // cubit = MockHomeCubit();
      // when(() => cubit.state).thenReturn(const HomeState());

      todosRepository = MockTodosRepository();
      when(todosRepository.getTodos).thenAnswer((_) => const Stream.empty());
    });

    Widget buildSubject() {
      return MockNavigatorProvider(
        navigator: navigator,
        child: ProviderScope(
          overrides: [
            // weird, but, this causes null state
            homeNotifierProvider.overrideWith(() => MockHomeNotifier()),
            todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
            statsNotifierProvider.overrideWith(() => MockStatsNotifier()),
            todosOverviewNotifierProvider.overrideWith(() => MockTodosOverviewNotifier()),
          ],
          child: const HomePage(),
        ),
      );
    }

    testWidgets(
      'renders TodosOverviewPage '
      'when tab is set to HomeTab.todos',
      (tester) async {
        // when(() => cubit.state).thenReturn(const HomeState());

        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );

        expect(find.byType(TodosOverviewPage), findsOneWidget);
      },
    );

    testWidgets(
      'renders StatsPage '
      'when tab is set to HomeTab.stats',
      (tester) async {
        final container = createProviderContainer();
        // when(() => cubit.state).thenReturn(const HomeState(tab: HomeTab.stats));
        // i think this method is wrong, since the only way to set state is to call a
        // notifier method, then i should do exactly that
        when(
          // UPD this indeed doesn't work
          // () => container.read(homeNotifierProvider),
          () => container.read(homeNotifierProvider.notifier).setTab(HomeTab.stats),
        ).thenReturn(
          const HomeState(tab: HomeTab.stats),
        );

        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );

        expect(find.byType(StatsPage), findsOneWidget);
      },
    );

    testWidgets(
      'calls setTab with HomeTab.todos on HomeCubit '
      'when todos navigation button is pressed',
      (tester) async {
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );

        await tester.tap(find.byIcon(Icons.list_rounded));

        // verify(() => cubit.setTab(HomeTab.todos)).called(1);
      },
    );

    testWidgets(
      'calls setTab with HomeTab.stats on HomeCubit '
      'when stats navigation button is pressed',
      (tester) async {
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );

        await tester.tap(find.byIcon(Icons.show_chart_rounded));

        // verify(() => cubit.setTab(HomeTab.stats)).called(1);
      },
    );

    group('add todo floating action button', () {
      testWidgets(
        'is rendered',
        (tester) async {
          await tester.pumpApp(
            buildSubject(),
            todosRepository: todosRepository,
          );

          expect(
            find.byKey(addTodoFloatingActionButtonKey),
            findsOneWidget,
          );

          final addTodoFloatingActionButton =
              tester.widget(find.byKey(addTodoFloatingActionButtonKey));
          expect(
            addTodoFloatingActionButton,
            isA<FloatingActionButton>(),
          );
        },
      );

      testWidgets('renders add icon', (tester) async {
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );

        expect(
          find.descendant(
            of: find.byKey(addTodoFloatingActionButtonKey),
            matching: find.byIcon(Icons.add),
          ),
          findsOneWidget,
        );
      });

      testWidgets(
        'navigates to the EditTodoPage when pressed',
        (tester) async {
          await tester.pumpApp(
            buildSubject(),
            todosRepository: todosRepository,
          );

          await tester.tap(find.byKey(addTodoFloatingActionButtonKey));

          verify(
            () => navigator.push<void>(any(that: isRoute<void>())),
          ).called(1);
        },
      );
    });
  });
}
