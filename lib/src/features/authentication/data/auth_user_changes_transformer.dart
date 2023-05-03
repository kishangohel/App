import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthUserChangesTransformer extends StreamTransformerBase<User?, User?> {
  final void Function(User user) onLogin;
  final void Function(User user) onLogout;

  AuthUserChangesTransformer({
    required this.onLogin,
    required this.onLogout,
  });

  @override
  Stream<User?> bind(Stream<User?> stream) {
    late StreamController<User?> controller;
    StreamSubscription<User?>? subscription;

    User? previousValue;

    controller = StreamController<User?>(
      onListen: () {
        subscription = stream.listen(
          (currentUser) {
            if (previousValue == null && currentUser != null) {
              onLogin(currentUser);
            } else if (previousValue != null && currentUser == null) {
              onLogout(previousValue!);
            }
            previousValue = currentUser;
            controller.add(currentUser);
          },
          onError: controller.addError,
          onDone: controller.close,
          cancelOnError: false,
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () => subscription?.cancel(),
    );

    return controller.stream;
  }
}
