import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:verifi/blocs/nfts/nfts_cubit.dart';
import 'package:verifi/blocs/profile/profile_cubit.dart';
import 'package:verifi/blocs/theme/theme_cubit.dart';
import 'package:verifi/models/pfp.dart';

class EditProfileModalBottomSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditProfileModalBottomSheetState();
}

class _EditProfileModalBottomSheetState
    extends State<EditProfileModalBottomSheet> {
  final _pageController = PageController();
  Color? _selectedThemeColor;
  final themeTab = const Tab(
    child: AutoSizeText(
      "Theme",
      maxLines: 1,
    ),
    height: 32.0,
  );
  final pfpTab = const Tab(
    child: AutoSizeText(
      "Profile Picture",
      maxLines: 1,
    ),
    height: 32.0,
  );

  @override
  Widget build(BuildContext context) {
    final isNftPfp = context.read<ProfileCubit>().pfp != null;
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16.0),
          // If pfp is an NFT, show tabs to change both theme color and pfp.
          // Otherwise, just show tab to change theme color.
          child: DefaultTabController(
            length: (isNftPfp) ? 2 : 1,
            child: Column(
              children: [
                TabBar(
                  indicatorColor: Theme.of(context).colorScheme.onSurface,
                  labelColor: Theme.of(context).colorScheme.onSurface,
                  labelStyle: Theme.of(context).textTheme.titleMedium,
                  tabs: (isNftPfp) ? [themeTab, pfpTab] : [themeTab],
                ),
                Expanded(
                  child: TabBarView(
                    children: (isNftPfp)
                        ? [
                            _changeThemeColorContents(setModalState),
                            _changeNftPfpContents(),
                          ]
                        : [
                            _changeThemeColorContents(setModalState),
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

  /// Modal sheet tab to change theme to different color.
  Widget _changeThemeColorContents(StateSetter setModalState) {
    // Only get the top six brightest colors
    final colors = context.read<ThemeCubit>().state.colors.take(8);
    // Circles filled with colors that user can choose as primary theme color
    final colorCircles = colors.map((color) {
      // When user taps color, add border around color to indicate selection
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
        // Grid of colors
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            children: colorCircles,
          ),
        ),
        // Update theme color button
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

  /// Modal sheet tab to edit profile picture by selecting NFT in wallet.
  Widget _changeNftPfpContents() {
    // If address linked, check for new NFTs first
    String? ethAddress = context.read<ProfileCubit>().ethAddress;
    assert(ethAddress != null);
    return FutureBuilder(
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
          return _pfpBottomPageView();
        }
      },
    );
  }

  Widget _pfpBottomPageView() {
    return BlocBuilder<NftsCubit, List<Pfp>>(
      builder: (context, nfts) {
        return (nfts.isNotEmpty)
            ? Column(
                children: [
                  Expanded(
                    child: _pfpNftsBottomPageView(nfts),
                  ),
                  _pfpNftsUpdateButton(),
                ],
              )
            : Center(
                child: AutoSizeText(
                  "No NFTs in wallet",
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
      },
    );
  }

  Widget _pfpNftsBottomPageView(List<Pfp> nfts) {
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
                child: Image(image: nfts[index].image),
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
        await context.read<ProfileCubit>().updatePfp(photo);
        context.read<ThemeCubit>().updateColors(
              await PaletteGenerator.fromImageProvider(photo.image),
            );
        Navigator.of(context).pop();
      },
      child: const Text(
        "Update",
      ),
    );
  }
}
