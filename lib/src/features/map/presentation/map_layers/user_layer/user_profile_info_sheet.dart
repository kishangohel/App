import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

class UserProfileInfoSheet extends StatelessWidget {
  final UserProfile profile;

  const UserProfileInfoSheet(this.profile);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: RandomAvatar(
              profile.displayName,
              trBackground: true,
            ),
          ),
          Expanded(
            child: ListTile(
              title: Text(
                profile.displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "VeriPoints: ${profile.veriPoints}",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
