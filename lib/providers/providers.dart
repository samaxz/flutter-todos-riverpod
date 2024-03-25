import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:mocktail/mocktail.dart';

part 'providers.g.dart';

@riverpod
TodosRepository todosRepository(TodosRepositoryRef ref) {
  throw UnimplementedError();
}

// this doesn't work with widget testing, but does work with unit testing
// any overridden method here throws ```Used on a non-mocktail object``` inside unit tests
class MockTodosRepository extends Mock implements TodosRepository {}

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
