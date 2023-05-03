import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verifi/src/routing/app_router.dart';

import 'display_name_screen_controller.dart';
import 'widgets/display_name_claim_button.dart';
import 'widgets/display_name_text_field.dart';

class DisplayNameScreen extends ConsumerStatefulWidget {
  const DisplayNameScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DisplayNameScreen> createState() => _DisplayNameScreenState();
}

class _DisplayNameScreenState extends ConsumerState<DisplayNameScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    ref.listen<AsyncValue<bool>>(
      displayNameScreenControllerProvider,
      (previous, current) {
        current.whenData((value) {
          if (value) {
            router.goNamed(AppRoute.profile.name);
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
                // Main content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              'Claim your display name',
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      // Subtitle
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: AutoSizeText(
                                'Your display name will be visible to other users.',
                                maxLines: 3,
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Text field
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: DisplayNameTextField(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Submit button
                Row(
                  children: [
                    Expanded(
                      child: DisplayNameClaimButton(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
