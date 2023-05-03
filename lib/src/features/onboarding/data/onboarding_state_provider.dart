import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/common/providers/shared_prefs.dart';

part '_generated/onboarding_state_provider.g.dart';

@Riverpod(keepAlive: true)
class OnboardingState extends _$OnboardingState {
  @override
  Future<bool> build() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    return prefs.getBool('onboarded') ?? false;
  }

  Future<void> complete() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs
        .setBool('onboarded', true)
        .then((success) => state = AsyncData(success));
  }
}
