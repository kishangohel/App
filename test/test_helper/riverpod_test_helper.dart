import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// A generic Listener class, used to keep track of when a provider notifies
/// its listeners.
class _StateListener<T> {
  final List<T> emitted = [];
  void call(T? previous, T next) {
    emitted.add(next);
  }
}

/// Simplifies testing of code which relies on riverpod.
@isTest
void riverpodTest<T>(
  /// The test description, usually a [String].
  Object description, {

  /// The target of the test.
  required ProviderListenable<T> providerListenable,

  /// Run setup code before setting overrides and running tests.
  FutureOr<void> Function()? setUp,

  /// The [Override]s which should be applied for this test.
  FutureOr<List<Override>> Function()? overrides,

  /// Interact with the provider and its dependencies before verification.
  FutureOr<void> Function(ProviderContainer)? act,

  /// Check the emitted states.
  required List<dynamic> expect,

  /// Run optional verifications (e.g. for called repositories)
  FutureOr<void> Function()? verify,

  /// Set [logProviders] to true to print out provider states for debugging.
  bool logProviders = false,
}) {
  flutter_test.test(
    description,
    () async {
      // Run setup
      if (setUp != null) await setUp();

      // Create container
      final container = ProviderContainer(
        overrides: overrides == null ? [] : await overrides(),
        observers: logProviders ? [_Logger()] : [],
      );
      flutter_test.addTearDown(container.dispose);

      // Setup listener
      final listener = _StateListener<T>();
      container.listen(
        providerListenable,
        listener,
        fireImmediately: true,
      );

      // Perform testing actions
      if (act != null) await act(container);

      // Check emitted states.
      flutter_test.expect(listener.emitted, flutter_test.wrapMatcher(expect));
    },
  );
}

/// Wrap [Widget] in a ProviderContainer with the specified provider
/// [overrides]. Set [logProviders] to true to print out provider states for
/// debugging purposes.
Future<ProviderContainer> makeWidgetWithRiverpod(
  flutter_test.WidgetTester tester, {
  Widget Function()? widget,
  List<Override> overrides = const [],
  bool logProviders = false,
  GoRouter? goRouter,
}) async {
  assert((widget == null) ^ (goRouter == null));

  final container = ProviderContainer(
    overrides: overrides,
    observers: logProviders ? [_Logger()] : [],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: widget != null
          ? MaterialApp(home: widget())
          : MaterialApp.router(
              routerConfig: goRouter!,
            ),
    ),
  );

  return container;
}

class _Logger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "newValue": "$newValue"
}''');
  }
}
