import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:verifi/blocs/nfts/nfts_cubit.dart';
import 'package:verifi/blocs/profile/profile_cubit.dart';
import 'package:verifi/blocs/theme/theme_cubit.dart';
import 'package:verifi/models/nft.dart';

class EditProfileModalBottomSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditProfileModalBottomSheetState();
}

class _EditProfileModalBottomSheetState
    extends State<EditProfileModalBottomSheet> {
  final _pageController = PageController();
  Color? _selectedThemeColor;

  @override
  Widget build(BuildContext context) {
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
                  labelStyle: Theme.of(context).textTheme.headline6?.copyWith(
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
    // If address linked, check for new NFTs first
    bool web3Enabled = context.read<ProfileCubit>().ethAddress != null;
    return (web3Enabled)
        ? FutureBuilder(
            future: context.read<NftsCubit>().loadNftsOwnedbyAddress(
                  context.read<ProfileCubit>().ethAddress!,
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
                return _pfpBottomPageView(web3Enabled);
              }
            },
          )
        : _pfpBottomPageView(web3Enabled);
  }

  Widget _pfpBottomPageView(bool web3Enabled) {
    return BlocBuilder<NftsCubit, List<Nft>>(
      builder: (context, nfts) {
        return (web3Enabled && nfts.isNotEmpty)
            ? Column(
                children: [
                  Expanded(
                    child: _pfpNftsBottomPageView(nfts),
                  ),
                  _pfpNftsUpdateButton(),
                ],
              )
            //TODO
            : Container();
      },
    );
  }

  Widget _pfpNftsBottomPageView(List<Nft> nfts) {
    return PageView.builder(
      controller: _pageController,
      itemCount: nfts.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image(image: nfts[index].image!),
              ),
            ),
            Visibility(
              visible: nfts[index].name != null,
              child: Expanded(
                flex: 1,
                child: AutoSizeText(
                  nfts[index].name ?? '',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
            Visibility(
              visible: nfts[index].description != null,
              child: Expanded(
                flex: 1,
                child: AutoSizeText(
                  nfts[index].description ?? "",
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _pfpNftsUpdateButton() {
    return ElevatedButton(
      onPressed: () async {
        final photo =
            context.read<NftsCubit>().state[_pageController.page!.toInt()];
        context.read<ProfileCubit>().setPfp(photo);
        context.read<ThemeCubit>().updateColors(
              await PaletteGenerator.fromImageProvider(photo.image!),
            );
        Navigator.of(context).pop();
      },
      child: const Text(
        "Update",
      ),
    );
  }
}
