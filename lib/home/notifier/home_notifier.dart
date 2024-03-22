import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:mocktail/mocktail.dart';

part 'home_notifier.g.dart';
part 'home_state.dart';

// for unit testing
class MockHomeNotifier extends _$HomeNotifier with Mock implements HomeNotifier {
  @override
  HomeState build() {
    return const HomeState();
  }
}

@riverpod
class HomeNotifier extends _$HomeNotifier {
  @override
  HomeState build() {
    return const HomeState();
  }

  void setTab(HomeTab tab) => state = HomeState(tab: tab);
}
