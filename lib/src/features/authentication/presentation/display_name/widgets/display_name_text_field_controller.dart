import 'package:riverpod_annotation/riverpod_annotation.dart';

part '_generated/display_name_text_field_controller.g.dart';

@riverpod
class DisplayNameTextFieldController extends _$DisplayNameTextFieldController {
  @override
  String build() => '';

  updateDisplayName(String displayName) => state = displayName;
}
