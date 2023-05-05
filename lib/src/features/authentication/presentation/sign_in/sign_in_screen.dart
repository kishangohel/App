import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verifi/src/features/authentication/presentation/sign_in/sign_in_screen_controller.dart';
import 'package:verifi/src/features/authentication/presentation/sign_in/widgets/phone_number_text_field.dart';
import 'package:verifi/src/features/authentication/presentation/sign_in/widgets/sign_in_title.dart';
import 'package:verifi/src/routing/app_router.dart';

import 'widgets/header_image.dart';
import 'widgets/sign_in_submit_button.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    // Controller listener
    ref.listen<AsyncValue<bool>>(
      signInScreenControllerProvider,
      (previous, current) {
        current.when(
          data: (value) {
            if (value) {
              router.goNamed(AppRoute.smsCode.name);
            }
          },
          loading: () {},
          error: (error, stacktrace) {
            debugPrint(error.toString());
          },
        );
      },
    );
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
        // Sign in form
        child: SafeArea(
          child: Column(
            children: [
              // Sign in header image
              Visibility(
                visible: MediaQuery.of(context).viewInsets.bottom == 0,
                child: AuthHeaderImage(),
              ),
              // Sign in content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Sign in title
                          SignInTitle(),
                        ],
                      ),
                    ),
                    // Phone number field
                    PhoneNumberTextField(),
                  ],
                ),
              ),
              // Submit button
              const SignInSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}
