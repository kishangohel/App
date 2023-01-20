// import 'package:auto_connect/auto_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verifi/src/features/access_points/data/auto_connect_repository.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/routing/app_router.dart';

class LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      child: const Text(
        "Logout",
      ),
      onPressed: () async {
        ref.read(autoConnectRepositoryProvider).removeAllGeofences();
        ref.read(authRepositoryProvider).signOut();
        context.pushNamed(AppRoute.displayName.name);
      },
    );
  }
}
