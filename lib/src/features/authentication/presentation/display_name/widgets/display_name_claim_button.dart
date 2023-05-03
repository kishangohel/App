import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/common/widgets/bottom_button.dart';
import 'package:verifi/src/features/authentication/presentation/display_name/display_name_screen_controller.dart';
import 'package:verifi/src/features/authentication/presentation/display_name/widgets/display_name_text_field_controller.dart';
import 'package:verifi/src/features/authentication/presentation/display_name/widgets/display_name_text_field_validator.dart';

class DisplayNameClaimButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final validator = ref.watch(displayNameTextFieldValidatorProvider);
    final controller = ref.watch(displayNameTextFieldControllerProvider);
    final screenController = ref.watch(displayNameScreenControllerProvider);
    return BottomButton(
      onPressed:
          (validator.isLoading || validator.value != null || controller.isEmpty)
              ? null
              : () async => await ref
                  .read(displayNameScreenControllerProvider.notifier)
                  .completeSetup(),
      text: validator.when<String>(
        data: (d) => (d == null && controller.isNotEmpty) ? 'Claim' : '',
        error: (_, __) => '',
        loading: () => 'Checking availability...',
      ),
      isLoading: validator.isLoading || screenController.isLoading,
    );
  }
}
