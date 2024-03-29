import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:mocktail/mocktail.dart';

part 'providers.g.dart';

@riverpod
TodosRepository todosRepository(TodosRepositoryRef ref) {
  throw UnimplementedError();
}

// any overridden method here throws ```Used on a non-mocktail object``` inside unit tests
class MockTodosRepository extends Mock implements TodosRepository {}
