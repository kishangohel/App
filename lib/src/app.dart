import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'routing/app_router.dart';

/// The top-level [Widget] for the VeriFi application.
/// This should only be built by calling [runApp] in [main].
class VeriFi extends ConsumerWidget {
  const VeriFi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp.router(
      routerConfig: goRouter,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(useMaterial3: true).textTheme,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
          ).textTheme,
        ),
        useMaterial3: true,
      ),
      color: const Color(0xff6f61ef),
    );
  }
}
