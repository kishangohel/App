import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/authentication/presentation/display_name/display_name_screen_controller.dart';
import 'package:verifi/src/features/authentication/presentation/widgets/onboarding_app_bar.dart';

import '../widgets/onboarding_outline_button.dart';

class DisplayNameScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DisplayNameScreenState();
}

class _DisplayNameScreenState extends ConsumerState<DisplayNameScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await ref.read(authRepositoryProvider).signOut();
        return true;
      },
      child: Scaffold(
        appBar: OnboardingAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _setupHeader(),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _displayNameTextField(),
                    _displayNameSubmitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setupHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AutoSizeText(
          "Enter your display name",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: AutoSizeText(
            "Your display name must be unique across all VeriFi users",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _displayNameTextField() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        errorStyle: Theme.of(context).textTheme.caption?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        errorText: ref.watch(displayNameScreenControllerProvider).maybeWhen(
              data: (value) => value,
              orElse: () => null,
            ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _displayNameSubmitButton() {
    final state = ref.watch(displayNameScreenControllerProvider);
    return OnboardingOutlineButton(
      onPressed: state.when<Future Function()?>(
        data: (state) {
          return () async => ref
              .read(displayNameScreenControllerProvider.notifier)
              .submitDisplayName(_controller.value.text);
        },
        error: (_, __) {
          return () async => ref
              .read(displayNameScreenControllerProvider.notifier)
              .submitDisplayName(_controller.value.text);
        },
        loading: () {
          return null;
        },
      ),
      child: state.when<Widget>(
        data: (state) => const AutoSizeText("Submit"),
        error: (_, __) => const AutoSizeText("Submit"),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
