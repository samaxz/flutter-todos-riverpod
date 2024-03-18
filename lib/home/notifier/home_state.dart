part of 'home_notifier.dart';

enum HomeTab { todos, stats }

final class HomeState extends Equatable {
  const HomeState({
    this.tab = HomeTab.todos,
  });

  final HomeTab tab;

  @override
  List<Object> get props => [tab];
}
