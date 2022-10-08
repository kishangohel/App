import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/profile_screen/edit_profile_modal_bottom_sheet.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text(
        "My Profile",
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _profilePhoto(),
          _profileName(),
          _logoutButton(),
        ],
      ),
    );
  }

  Widget _profilePhoto() {
    final pfp = context.read<ProfileCubit>().pfp;
    final pfpType = context.read<ProfileCubit>().pfpType;
    assert(pfp != null && pfpType != null);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: ProfileCubit.pfpToImage(pfp!, pfpType!),
                  backgroundColor: Theme.of(context).colorScheme.background,
                ),
              ),
              Positioned(
                bottom: -2,
                child: RawMaterialButton(
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  fillColor: Theme.of(context).colorScheme.primary,
                  elevation: 2.0,
                  shape: const CircleBorder(),
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                  onPressed: () => _showEditProfileBottomSheet(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileName() {
    final displayName = context.watch<ProfileCubit>().displayName;
    return Text(
      displayName ?? '',
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _logoutButton() {
    return ElevatedButton(
      child: const Text(
        "Logout",
      ),
      onPressed: () async {
        await context.read<ProfileCubit>().clear();
        context.read<ProfileCubit>().logout();
        context.read<AuthenticationCubit>().logout();
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding',
          (route) => false,
        );
      },
    );
  }

  void _showEditProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return EditProfileModalBottomSheet();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
