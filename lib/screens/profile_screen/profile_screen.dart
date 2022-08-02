import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/nfts/nfts.dart';
import 'package:verifi/blocs/theme/theme_cubit.dart';

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
  final _pageController = PageController();

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
        SizedBox(
          height: 150,
          width: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: _backgroundImage,
                  backgroundColor: Theme.of(context).colorScheme.background,
                ),
              ),
              Positioned(
                bottom: -8,
                child: RawMaterialButton(
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  fillColor: Theme.of(context).colorScheme.secondary,
                  elevation: 2.0,
                  shape: const CircleBorder(),
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.onSecondary,
                    size: 18,
                  ),
                  onPressed: () => _showPfpBottomSheet(),
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
      style: Theme.of(context).textTheme.headline4?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _logoutButton() {
    return ElevatedButton(
      child: const Text(
        "Logout",
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

  void _showPfpBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: context.read<NftsCubit>().loadNftsOwnedbyAddress(
                  /* context.read<ProfileCubit>().ethAddress!, */
                  "0x062D6D315e6C8AA196b9072d749E3f3F3579fDD0",
                ),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(),
                );
              } else {
                return _pfpBottomPageView();
              }
            },
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _pfpBottomPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: context.read<NftsCubit>().state.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CachedNetworkImage(
                  imageUrl: context.read<NftsCubit>().state[index].image,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: AutoSizeText(
                context.read<NftsCubit>().state[index].name,
                maxLines: 1,
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
            Expanded(
              flex: 1,
              child: AutoSizeText(
                context.read<NftsCubit>().state[index].collectionName,
                maxLines: 1,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () async {
                  final photo = context
                      .read<NftsCubit>()
                      .state[_pageController.page!.toInt()]
                      .image;
                  context.read<ProfileCubit>().setProfilePhoto(photo);
                  context.read<ThemeCubit>().updateColors(
                        await PaletteGenerator.fromImageProvider(
                          NetworkImage(photo),
                        ),
                      );
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Make profile picture",
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
