import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verifi/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:verifi/src/features/authentication/presentation/sms_code/widgets/sms_code_input_text_field.dart';
import 'package:verifi/src/routing/app_router.dart';

import 'sms_code_screen_controller.dart';
import 'widgets/sms_code_submit_button.dart';
import 'package:verifi/src/utils/async_value_ui.dart';

class SmsCodeScreen extends ConsumerStatefulWidget {
  const SmsCodeScreen({super.key});

  @override
  ConsumerState<SmsCodeScreen> createState() => _SmsCodeScreenState();
}

class _SmsCodeScreenState extends ConsumerState<SmsCodeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final unfocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    // Controller listener
    ref.listen<AsyncValue<void>>(
      smsCodeScreenControllerProvider,
      (_, state) => state.showSnackbarOnError(context),
    );
    // Firebase auth listener
    ref.watch(firebaseAuthStateChangesProvider).whenData((user) {
      if (user != null) {
        if (user.displayName == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            router.goNamed(AppRoute.displayName.name);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            router.goNamed(AppRoute.profile.name);
          });
        }
      }
    });
    // Widget
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(unfocusNode),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Enter SMS Code',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: SmsCodeInputTextField(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SmsCodeSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
