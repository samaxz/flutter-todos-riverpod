// // ignore_for_file: prefer_const_constructors
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_todos/edit_todo/notifier/edit_todo_notifier.dart';
// import 'package:flutter_todos/providers/providers.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:todos_repository/todos_repository.dart';
//
// class MockTodosRepository extends Mock implements TodosRepository {}
//
// class Listener<T> extends Mock {
//   void call(T? previous, T next);
// }
//
// void main() {
//   ProviderContainer createProviderContainer() {
//     final container = ProviderContainer(
//       overrides: [
//         todosRepositoryProvider.overrideWithValue(MockTodosRepository()),
//       ],
//     );
//     // this throws, since it can only be used inside tests
//     // addTearDown(container.dispose);
//     return container;
//   }
//
//   group('EditTodoEvent', () {
//     group('EditTodoTitleChanged', () {
//       test('supports value equality', () {
//         final container = createProviderContainer();
//         expect(
//           // EditTodoTitleChanged('title'),
//           container.read(editTodoNotifierProvider().notifier)..changeTitle('new_title'),
//           equals(EditTodoState(title: 'new_title')),
//         );
//       });
//
//       test('props are correct', () {
//         expect(
//           EditTodoTitleChanged('title').props,
//           equals(<Object?>[
//             'title', // title
//           ]),
//         );
//       });
//     });
//
//     group('EditTodoDescriptionChanged', () {
//       test('supports value equality', () {
//         expect(
//           EditTodoDescriptionChanged('description'),
//           equals(EditTodoDescriptionChanged('description')),
//         );
//       });
//
//       test('props are correct', () {
//         expect(
//           EditTodoDescriptionChanged('description').props,
//           equals(<Object?>[
//             'description', // description
//           ]),
//         );
//       });
//     });
//
//     group('EditTodoSubmitted', () {
//       test('supports value equality', () {
//         expect(
//           EditTodoSubmitted(),
//           equals(EditTodoSubmitted()),
//         );
//       });
//
//       test('props are correct', () {
//         expect(
//           EditTodoSubmitted().props,
//           equals(<Object?>[]),
//         );
//       });
//     });
//   });
// }
