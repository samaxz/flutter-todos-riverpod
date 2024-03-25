import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:mocktail/mocktail.dart';

part 'providers.g.dart';

@riverpod
TodosRepository todosRepository(TodosRepositoryRef ref) {
  throw UnimplementedError();
}

// this doesn't work with widget testing, but does with unit testing
class MockTodosRepository extends Mock implements TodosRepository {
  // this throws
  // Stream<List<Todo>> getTodos() => Stream.empty();

  // this throws ```Used on a non-mocktail object```
  // @override
  // Future<void> saveTodo(Todo todo) => Future.value(todo);
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
