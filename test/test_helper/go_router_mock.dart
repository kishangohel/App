import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class GoRouterMock extends Mock implements GoRouter {}

Widget mockGoRouter(
  GoRouterMock goRouterMock, {
  required Widget child,
}) =>
    InheritedGoRouter(
      goRouter: goRouterMock,
      child: child,
    );
