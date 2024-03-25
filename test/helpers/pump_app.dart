import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:todos_repository/todos_repository.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    TodosRepository? todosRepository,
    Todo? initialTodo,
    // TODO pass overrides here
    // List<Override> overrides = const [],
  }) {
    return pumpWidget(
      ProviderScope(
        // overrides: [
        //   todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
        //   // editTodoNotifierProvider(initialTodo: initialTodo)
        //   // editTodoNotifierProvider().overrideWith(() => mockEditTodoNotifier),
        //   editTodoNotifierProvider(initialTodo: initialTodo)
        //       .overrideWith(() => MockEditTodoNotifier.new()),
        // ],
        // overrides: overrides,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: widget),
        ),
      ),
    );
  }

  Future<void> pumpRoute(
    Route<dynamic> route, {
    TodosRepository? todosRepository,
    Todo? initialTodo,
    List<Override> overrides = const [],
  }) {
    return pumpApp(
      Navigator(onGenerateRoute: (_) => route),
      todosRepository: todosRepository,
      initialTodo: initialTodo,
      // overrides: overrides,
    );
  }
}
