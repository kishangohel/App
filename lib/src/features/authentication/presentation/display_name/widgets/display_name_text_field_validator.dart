import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/presentation/display_name/widgets/display_name_text_field_controller.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part '_generated/display_name_text_field_validator.g.dart';

@riverpod
class DisplayNameTextFieldValidator extends _$DisplayNameTextFieldValidator {
  /// Null means the display name is available.
  /// Otherwise, the string is the error message.
  @override
  FutureOr<String?> build() => null;

  void setLoading() => state = const AsyncLoading<String?>();

  Future<void> validateDisplayName(String? displayName) async {
    final displayName = ref.read(displayNameTextFieldControllerProvider);
    state = await AsyncValue.guard<String?>(() async {
      if (displayName.isEmpty) {
        return null;
      }
      return await ref
          .read(profileRepositoryProvider)
          .validateDisplayName(displayName);
    });
  }
}
