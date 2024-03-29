import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/app/app.dart';
import 'package:flutter_todos/home/home.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:flutter_todos/theme/theme.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late MockTodosRepository mockTodosRepository;

  setUp(() {
    mockTodosRepository = MockTodosRepository();
    when(
      () => mockTodosRepository.getTodos(),
    ).thenAnswer(
      (_) => const Stream.empty(),
    );
  });

  group('App', () {
    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todosRepositoryProvider.overrideWith((ref) => mockTodosRepository),
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
            todosRepositoryProvider.overrideWith((ref) => mockTodosRepository),
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
            todosRepositoryProvider.overrideWith((ref) => mockTodosRepository),
          ],
          child: App(),
        ),
      );

      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
