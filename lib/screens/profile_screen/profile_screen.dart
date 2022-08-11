import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/nfts/nfts_cubit.dart';
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
  Color? _selectedThemeColor;

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
    final photoUrl = context.watch<ProfileCubit>().pfp;
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
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: _backgroundImage,
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

  void _showEditProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              color: Theme.of(context).colorScheme.surface,
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(16.0),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: Theme.of(context).colorScheme.onSurface,
                      labelColor: Theme.of(context).colorScheme.onSurface,
                      labelStyle:
                          Theme.of(context).textTheme.headline6?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                      tabs: const [
                        Tab(
                          child: AutoSizeText(
                            "Theme",
                            maxLines: 1,
                          ),
                          height: 32.0,
                        ),
                        Tab(
                          child: AutoSizeText(
                            "Profile Picture",
                            maxLines: 1,
                          ),
                          height: 32.0,
                        ),
                      ],
                    ),
                    Expanded(
                      flex: 6,
                      child: TabBarView(
                        children: [
                          _changeThemeContents(setModalState),
                          _editProfileContents(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _changeThemeContents(StateSetter setModalState) {
    final colors = context.read<ThemeCubit>().state.colors;
    final colorCubes = colors.map((color) {
      return GestureDetector(
        onTap: () => setModalState(() => _selectedThemeColor = color),
        child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(36),
            ),
            child: (_selectedThemeColor == color)
                ? const Icon(Icons.check)
                : null),
      );
    }).toList(growable: false);
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            children: colorCubes,
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final _color = _selectedThemeColor;
            if (_color != null) {
              context.read<ThemeCubit>().updateThemeWithColor(_color);
            }
            Navigator.of(context).pop();
          },
          child: const Text(
            "Update",
          ),
        ),
      ],
    );
  }

  Widget _editProfileContents() {
    bool web3Enabled = context.read<ProfileCubit>().ethAddress != null;
    return (web3Enabled)
        ? FutureBuilder(
            future: context.read<NftsCubit>().loadNftsOwnedbyAddress(
                  /* context.read<ProfileCubit>().ethAddress!, */
                  "0x062D6D315e6C8AA196b9072d749E3f3F3579fDD0",
                ),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return _pfpNftsBottomPageView();
              }
            },
          )
        : _pfpAvatarsBottomPageView();
  }

  Widget _pfpNftsBottomPageView() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: context.read<NftsCubit>().state.length,
            itemBuilder: (context, index) {
              final pfp = context.read<NftsCubit>().state[index];
              return Column(
                children: [
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CachedNetworkImage(
                        imageUrl: context.read<NftsCubit>().state[index].image,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: pfp.name != null,
                    child: Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        pfp.name ?? '',
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: pfp.collectionName != null,
                    child: Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        context
                                .read<NftsCubit>()
                                .state[index]
                                .collectionName ??
                            "",
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final photo = context
                .read<NftsCubit>()
                .state[_pageController.page!.toInt()]
                .image;
            context.read<ProfileCubit>().setPfp(photo);
            context.read<ThemeCubit>().updateColors(
                  await PaletteGenerator.fromImageProvider(
                    NetworkImage(photo),
                  ),
                );
            Navigator.of(context).pop();
          },
          child: const Text(
            "Update",
          ),
        ),
      ],
    );
  }

  Widget _pfpAvatarsBottomPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: context.read<NftsCubit>().state.length,
      itemBuilder: (context, index) {
        final pfp = context.read<NftsCubit>().state[index];
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
            Visibility(
              visible: pfp.name != null,
              child: Expanded(
                flex: 1,
                child: AutoSizeText(
                  pfp.name ?? '',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
            ),
            Visibility(
              visible: pfp.collectionName != null,
              child: Expanded(
                flex: 1,
                child: AutoSizeText(
                  context.read<NftsCubit>().state[index].collectionName ?? "",
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headline5,
                ),
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
                  context.read<ProfileCubit>().setPfp(photo);
                  context.read<ThemeCubit>().updateColors(
                        await PaletteGenerator.fromImageProvider(
                          NetworkImage(photo),
                        ),
                      );
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Update",
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
