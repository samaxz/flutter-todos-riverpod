import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:equatable/equatable.dart';

part 'home_notifier.g.dart';
part 'home_state.dart';

@riverpod
class HomeNotifier extends _$HomeNotifier {
  @override
  HomeState build() {
    return const HomeState();
  }

  void setTab(HomeTab tab) => state = HomeState(tab: tab);
}
