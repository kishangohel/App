import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'display_name_text_field_controller.dart';
import 'display_name_text_field_validator.dart';

class DisplayNameTextField extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final validator = ref.watch(displayNameTextFieldValidatorProvider);
    final displayName = ref.watch(displayNameTextFieldControllerProvider);

    return TextFormField(
      decoration: InputDecoration(
        errorText: validator.valueOrNull,
        errorStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
        errorMaxLines: 5,
        helperText: validator.when<String?>(
          data: (d) {
            if (d == null) {
              if (displayName.isNotEmpty) {
                return '$displayName is available';
              } else {
                return null;
              }
            } else {
              return d;
            }
          },
          error: (_, __) => null,
          loading: () => null,
        ),
        helperStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
        helperMaxLines: 1,
        labelText: 'Display Name',
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: (validator.valueOrNull == null)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.background,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 16, 0, 16),
      ),
      onChanged: (value) {
        ref.read(displayNameTextFieldValidatorProvider.notifier).setLoading();
        EasyDebounce.debounce(
          'displayNameOnChanged',
          const Duration(milliseconds: 300),
          () async {
            ref
                .read(displayNameTextFieldControllerProvider.notifier)
                .updateDisplayName(value);
            ref
                .read(displayNameTextFieldValidatorProvider.notifier)
                .validateDisplayName(value);
          },
        );
      },
    );
  }
}
