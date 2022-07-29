import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/display_name_textfield/display_name_textfield_bloc.dart';
import 'package:verifi/blocs/profile/profile_cubit.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';
import 'package:verifi/widgets/text/app_title.dart';

class DisplayNameScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DisplayNameScreenState();
}

class _DisplayNameScreenState extends State<DisplayNameScreen> {
  double opacity = 0;
  Color _fontColor = Colors.black;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () => setState(() => opacity = 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) _fontColor = Colors.white;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Hero(
          tag: 'verifi-logo',
          child: Image.asset('assets/launcher_icon/vf_ios.png'),
        ),
        title: const Hero(
          tag: 'verifi-title',
          child: AppTitle(),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              ...onBoardingBackground(context),
              _displayNameScreenContents(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _displayNameScreenContents() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _displayNameScreenTop(),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _displayNameScreenBottom(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayNameScreenTop() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: AutoSizeText(
            "Enter your display name",
            style: Theme.of(context).textTheme.headline1?.copyWith(
                  color: _fontColor,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: AutoSizeText(
            "Your display name must be unique across all VeriFi users",
            style: Theme.of(context).textTheme.headline6?.copyWith(),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _displayNameScreenBottom() {
    return BlocBuilder<DisplayNameTextfieldBloc, DisplayNameTextfieldState>(
      builder: (context, displayNameState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              cursorColor: _fontColor,
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _fontColor,
                  ),
                ),
                errorStyle: Theme.of(context).textTheme.caption?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                errorText: (displayNameState.errorText != null)
                    ? displayNameState.errorText
                    : null,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2.0,
                    color: _fontColor,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2.0,
                    color: _fontColor,
                  ),
                ),
              ),
              onChanged: (text) {
                context.read<DisplayNameTextfieldBloc>().add(
                      DisplayNameTextfieldUpdating(),
                    );
                context.read<DisplayNameTextfieldBloc>().add(
                      DisplayNameTextfieldUpdated(text),
                    );
              },
            ),
            Visibility(
              visible: displayNameState.displayName != null &&
                  displayNameState.displayName!.isNotEmpty &&
                  displayNameState.errorText == null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: OutlinedButton(
                  child: Text(
                    "Claim display name",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  onPressed: () {
                    assert(displayNameState.displayName != null);
                    context.read<ProfileCubit>().setDisplayName(
                          displayNameState.displayName!,
                        );

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/onboarding/wallet',
                      ModalRoute.withName('/onboarding/displayName'),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _fontColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
