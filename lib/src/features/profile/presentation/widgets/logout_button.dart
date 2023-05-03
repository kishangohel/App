import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/features/authentication/data/firebase_auth_repository.dart';

class LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      child: const Text(
        "Logout",
      ),
      onPressed: () => ref.read(firebaseAuthRepositoryProvider).signOut(),
    );
  }
}
