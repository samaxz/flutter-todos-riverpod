import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/home/notifier/home_notifier.dart';
import 'package:mocktail/mocktail.dart';

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  ProviderContainer createProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        // weird, but, this causes null state
        // homeNotifierProvider.overrideWith(() => MockHomeNotifier()),
      ],
    );
    // this throws, since it can only be used inside tests
    // addTearDown(container.dispose);
    return container;
  }

  group('HomeNotifier', () {
    group('constructor', () {
      test('works properly', () {
        // expect(buildCubit, returnsNormally);
        expect(createProviderContainer, returnsNormally);
      });

      test('has correct initial state', () {
        expect(
          // buildCubit().state,
          createProviderContainer().read(homeNotifierProvider),
          equals(const HomeState()),
        );
      });
    });

    test('sets tab to given value', () {
      final container = createProviderContainer();
      final listener = Listener<HomeState>();
      container.listen(
        homeNotifierProvider,
        listener,
        fireImmediately: true,
      );
      container.read(homeNotifierProvider.notifier).setTab(HomeTab.stats);
      // both work
      verify(
        () => listener(
          HomeState(),
          HomeState(tab: HomeTab.stats),
        ),
      );
      // expect(
      //   container.read(homeNotifierProvider),
      //   HomeState(tab: HomeTab.stats),
      // );
    });
  });
}
