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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    ref.listen<AsyncValue<bool>>(
      signInScreenControllerProvider,
      (previous, current) {
        current.whenData((value) {
          if (value) {
            router.goNamed(AppRoute.smsCode.name);
          }
        });
      },
    );
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.all(16.0),
        // Sign in form
        child: SafeArea(
          child: Form(
            key: _formKey,
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
                      // Submit button
                    ],
                  ),
                ),
                SignInSubmitButton(
                  formKey: _formKey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
