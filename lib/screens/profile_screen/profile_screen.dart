import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: Image.asset('assets/launcher_icon/vf_ios.png'),
      title: Text(
        "My Profile",
        style: Theme.of(context)
            .textTheme
            .headline5
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class ProfileBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _profilePhoto(),
          _profileName(),
        ],
      ),
    );
  }

  Widget _profilePhoto() {
    final photoUrl = context.watch<ProfileCubit>().profilePhoto;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: CircleAvatar(
            radius: 55,
            backgroundImage:
                (photoUrl != null) ? NetworkImage(photoUrl) : null,
            backgroundColor: Theme.of(context).colorScheme.background,
          ),
        )
      ],
    );
  }

  Widget _profileName() {
    final displayName = context.watch<ProfileCubit>().displayName;
    return Text(
      displayName ?? '',
      style: Theme.of(context).textTheme.headline4?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600),
    );
  }
}
