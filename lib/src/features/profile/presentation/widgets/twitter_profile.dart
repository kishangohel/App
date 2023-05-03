import 'package:flutter/material.dart';
import 'package:verifi/src/features/authentication/domain/current_user_model.dart';

class TwitterProfile extends StatelessWidget {
  static const _avatarSize = 20.0;

  final LinkedTwitterAccount twitterAccount;

  const TwitterProfile({
    super.key,
    required this.twitterAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        twitterAccount.photoUrl == null
            ? _missingProfilePhotoAvatar()
            : _profileAvatar(twitterAccount.photoUrl!),
        const SizedBox(width: 12),
        Text(
          twitterAccount.displayName,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _profileAvatar(String photoUrl) {
    return CircleAvatar(
      radius: _avatarSize,
      backgroundImage: NetworkImage(
        twitterAccount.photoUrl!,
      ),
    );
  }

  Widget _missingProfilePhotoAvatar() {
    return CircleAvatar(
      radius: _avatarSize,
      backgroundColor: Colors.grey.shade200,
      child: Icon(
        Icons.account_circle,
        color: Colors.grey.shade500,
      ),
    );
  }
}
