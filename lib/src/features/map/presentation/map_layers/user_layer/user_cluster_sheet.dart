import 'package:flutter/material.dart';
import 'package:verifi/src/common/widgets/expandable_page_view.dart';
import 'package:verifi/src/features/map/presentation/map_layers/user_layer/user_profile_info_sheet.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

class UserClusterSheet extends StatelessWidget {
  final List<UserProfile> users;

  const UserClusterSheet(this.users);

  @override
  Widget build(BuildContext context) {
    return ExpandablePageView(
      itemCount: users.length,
      controller: PageController(viewportFraction: 0.9),
      itemBuilder: (_, i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            color: Colors.grey.shade200,
            surfaceTintColor: Colors.grey.shade200,
            elevation: 6,
            child: UserProfileInfoSheet(users[i]),
          ),
        );
      },
    );
  }
}
