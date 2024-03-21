import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/app/app.dart';
import 'package:flutter_todos/home/home.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:flutter_todos/theme/theme.dart';
import 'package:local_storage_todos_api/local_storage_todos_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

import 'helpers/helpers.dart';

void main() {
  // late TodosRepository todosRepository;
  late MockTodosRepository todosRepository;

  ProviderContainer createProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
        // todosRepositoryProvider.overrideWithValue(MockFakeTodosRepository()),
      ],
    );
    // this throws, since it can only be used inside tests
    // addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    // todosRepository = MockTodosRepository();
    todosRepository = MockTodosRepository();

    when(
      () => createProviderContainer().read(todosRepositoryProvider).getTodos(),
    ).thenAnswer((_) => const Stream.empty());
    // ).thenAnswer((_) => null);
  });

  group('App', () {
    testWidgets('renders AppView', (tester) async {
      // TODO remove these, as they prevent the test from going
      // final todosApi = LocalStorageTodosApi(
      //   plugin: await SharedPreferences.getInstance(),
      // );
      // final todosRepository = TodosRepository(todosApi: todosApi);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
            todosRepositoryProvider.overrideWithValue(FakeTodosRepository()),
            // todosRepositoryProvider.overrideWithValue(MockFakeTodosRepository()),
            // todosRepositoryProvider.overrideWithValue(todosRepository),
          ],
          child: App(),
        ),
      );

      expect(find.byType(App), findsOneWidget);
    });
  });

  group('AppView', () {
    testWidgets('renders MaterialApp with correct themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
            todosRepositoryProvider.overrideWithValue(FakeTodosRepository()),
            // todosRepositoryProvider.overrideWithValue(MockFakeTodosRepository()),
          ],
          child: App(),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, equals(FlutterTodosTheme.light));
      expect(materialApp.darkTheme, equals(FlutterTodosTheme.dark));
    });

    testWidgets('renders HomePage', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
            todosRepositoryProvider.overrideWithValue(FakeTodosRepository()),
            // todosRepositoryProvider.overrideWithValue(MockFakeTodosRepository()),
          ],
          child: App(),
        ),
      );

      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
