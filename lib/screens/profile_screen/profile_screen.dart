import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/nfts/nfts.dart';
import 'package:verifi/blocs/theme/theme_cubit.dart';
import 'package:verifi/models/profile.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: Image.asset('assets/launcher_icon/vf_ios.png'),
      title: Text(
        "My Profile",
        style: Theme.of(context).textTheme.headline5?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
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
          _colorPaletteSelector(),
          _profileName(),
          _logoutButton(),
        ],
      ),
    );
  }

  Widget _profilePhoto() {
    final photoUrl = context.watch<ProfileCubit>().profilePhoto;
    ImageProvider<Object>? _backgroundImage;
    if (photoUrl != null) {
      if (photoUrl.contains("http")) {
        _backgroundImage = CachedNetworkImageProvider(photoUrl);
      } else {
        _backgroundImage = AssetImage(photoUrl);
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: CircleAvatar(
            radius: 55,
            backgroundImage: _backgroundImage,
            backgroundColor: Theme.of(context).colorScheme.background,
          ),
        )
      ],
    );
  }

  Widget _colorPaletteSelector() {
    final palettes =
        context.watch<ThemeCubit>().state.palette?.paletteColors ?? [];
    print(palettes);
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: palettes.length,
              itemBuilder: (context, index) {
                return CircleAvatar(
                  backgroundColor: palettes[index].color,
                );
              },
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
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

  Widget _logoutButton() {
    return ElevatedButton(
      child: Text(
        "Logout",
        style: Theme.of(context).textTheme.button?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
      onPressed: () {
        context.read<ProfileCubit>().clear();
        context.read<ProfileCubit>().logout();
        context.read<AuthenticationCubit>().logout().then(
              (value) => Navigator.of(context).pushNamedAndRemoveUntil(
                '/onboarding',
                (route) => false,
              ),
            );
      },
    );
  }
}
