import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

// this doesn't work with widget testing, but does with unit testing
class MockTodosRepository extends Mock implements TodosRepository {
  // this throws
  // Stream<List<Todo>> getTodos() => Stream.empty();
}

// this works with widget testing
class FakeTodosRepository implements TodosRepository {
  @override
  Future<int> clearCompleted() => Future.value(42);

  @override
  Future<int> completeAll({required bool isCompleted}) => Future.value(42);

  @override
  Future<void> deleteTodo(String id) => Future.value(id);

  @override
  Stream<List<Todo>> getTodos() => Stream.empty();

  @override
  Future<void> saveTodo(Todo todo) => Future.value(todo);
}

// this doesn't work with widget testing
// TODO remove this
// class MockFakeTodosRepository extends Mock implements FakeTodosRepository {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    TodosRepository? todosRepository,
  }) {
    return pumpWidget(
      ProviderScope(
        // TODO add overrides here
        overrides: [],
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
  }) {
    return pumpApp(
      Navigator(onGenerateRoute: (_) => route),
      todosRepository: todosRepository,
    );
  }
}
