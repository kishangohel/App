import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_screen_controller.g.dart';

/// We need to keep track of current page in order to ensure auth token
/// refreshes don't redirect user. By having `initialLocation` in
/// app_router.dart set to the state of this `Notifier`, auth token refreshes
/// won't interrupt the user.
@Riverpod(keepAlive: true)
class HomeScreenController extends _$HomeScreenController {
  @override
  String build() => '/profile';

  void setPage(String page) => state = page;
}
