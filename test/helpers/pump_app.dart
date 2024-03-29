import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/edit_todo/notifier/edit_todo_notifier.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/providers/providers.dart';
import 'package:todos_repository/todos_repository.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    TodosRepository? mockTodosRepository,
    Todo? initialTodo,
    MockEditTodoNotifier? mockEditTodoNotifier,
  }) {
    return pumpWidget(
      ProviderScope(
        overrides: [
          if (mockTodosRepository != null)
            todosRepositoryProvider.overrideWith((ref) => mockTodosRepository),
          if (mockEditTodoNotifier != null)
            editTodoNotifierProvider(initialTodo: initialTodo).overrideWith(
              () => mockEditTodoNotifier,
            ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      ),
    );
  }

  Future<void> pumpRoute(
    Route<dynamic> route, {
    TodosRepository? mockTodosRepository,
    Todo? initialTodo,
  }) {
    return pumpApp(
      Navigator(onGenerateRoute: (_) => route),
      mockTodosRepository: mockTodosRepository,
      initialTodo: initialTodo,
    );
  }
}
