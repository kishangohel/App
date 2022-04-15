import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/create_profile/create_profile_cubit.dart';
import 'package:verifi/models/profile.dart';

class CreateProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateProfilePageState();
}

class CreateProfilePageState extends State<CreateProfilePage> {
  int? _selectedAvatar;

  void _updateSelectedAvatar(int index) {
    setState(() => _selectedAvatar = index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _stepOneSubtitle(),
        _avatarCarousel(context),
        _stepTwoSubtitle(),
        _userCreateTextField(context),
      ],
    );
  }

  Widget _stepOneSubtitle() {
    return SizedBox(
      child: Text(
        "Step 1 - Select your Avatar",
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget _stepTwoSubtitle() {
    return SizedBox(
      child: Text(
        "Step 2 - Create your Username",
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget _avatarCarousel(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List<String>.generate(24, (i) {
          return (i % 2 != 0 ? i + 1 : (i + 13) % 24)
              .toString()
              .padLeft(2, "0");
        }).map<Widget>((avatarIndex) {
          final assetPath = "assets/profile_avatars/People-$avatarIndex.png";
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  _updateSelectedAvatar(int.parse(avatarIndex));
                  context.read<CreateProfileCubit>().photoChanged(assetPath);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.12,
                    backgroundImage: AssetImage(assetPath),
                  ),
                ),
              ),
              Visibility(
                visible: _selectedAvatar == int.parse(avatarIndex),
                child: const Icon(Icons.check),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _userCreateTextField(BuildContext context) {
    return BlocBuilder<CreateProfileCubit, Profile>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, createProfileState) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextFormField(
            initialValue: createProfileState.username.value,
            onChanged: (username) {
              context.read<CreateProfileCubit>().usernameChanged(username);
            },
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: Theme.of(context).textTheme.caption,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0,
                ),
              ),
              helperText: '',
              errorText: createProfileState.username.invalid
                  ? "Username not available"
                  : null,
            ),
            style: Theme.of(context).textTheme.bodyText2,
          ),
        );
      },
    );
  }
}
