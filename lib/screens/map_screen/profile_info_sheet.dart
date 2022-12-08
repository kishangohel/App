import 'package:flutter/material.dart';
import 'package:verifi/models/models.dart';

class ProfileInfoSheet extends StatelessWidget {
  final Profile profile;

  const ProfileInfoSheet(this.profile);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Image(image: profile.pfp!.image),
          ),
          Expanded(
            child: ListTile(
              title: Text(
                profile.displayName ?? "Unknown User",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contributed: ${profile.contributed ?? 0}",
                  ),
                  Text(
                    "Validated: ${profile.validated ?? 0}",
                  ),
                  Text(
                    "Eth address: ${profile.ethAddress ?? "Unknown"}",
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
