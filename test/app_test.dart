import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/app/app.dart';
import 'package:flutter_todos/home/home.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:flutter_todos/theme/theme.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/helpers.dart';

void main() {
  ProviderContainer createProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
      ],
    );
    // this throws, since it can only be used inside tests
    // addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    when(
      () => createProviderContainer().read(todosRepositoryProvider).getTodos(),
    ).thenAnswer((_) => const Stream.empty());
  });

  group('App', () {
    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todosRepositoryProvider.overrideWithValue(FakeTodosRepository()),
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
            todosRepositoryProvider.overrideWithValue(FakeTodosRepository()),
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
            todosRepositoryProvider.overrideWithValue(FakeTodosRepository()),
          ],
          child: App(),
        ),
      );

      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
