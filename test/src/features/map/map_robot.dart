import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MapRobot {
  final WidgetTester tester;
  MapRobot(this.tester);

  /////////////////////////////////////////////////////////////////////////////
  // FilterMapButton //////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////

  ElevatedButton findFilterMapButton() {
    return tester.widget<ElevatedButton>(
      find.byKey(const Key('filter_map_button_elevatedButton')),
    );
  }

  /////////////////////////////////////////////////////////////////////////////
  // FilterMapDialog //////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////

  CheckboxListTile findFilterMapDialogCheckboxListTile(String title) {
    return tester.widget<CheckboxListTile>(
      find.byKey(Key('filter_map_dialog_checkbox_$title')),
    );
  }

  Future<void> tapFilterMapDialogCheckboxListTile(String title) async {
    await tester.tap(find.byKey(Key('filter_map_dialog_checkbox_$title')));
    await tester.pumpAndSettle();
  }
}
