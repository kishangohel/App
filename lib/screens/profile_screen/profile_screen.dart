import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authenticationState) {
        return Column(
          children: <Widget>[
            _buildProfilePhoto(authenticationState.user?.photo),
            Center(
              child: Text(
                '${authenticationState.user?.username}',
                style: Theme.of(context).textTheme.headline4?.copyWith(
                      color: Colors.black,
                    ),
              ),
            ),
            ElevatedButton(
              child: Text('Logout',
                  style: Theme.of(context).textTheme.button?.copyWith(
                        color: Colors.white,
                      )),
              onPressed: () {
                BlocProvider.of<AuthenticationCubit>(context).logout();
                Navigator.of(context).pushReplacementNamed('/auth');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfilePhoto(String? photoUrl) {
    return (photoUrl != null)
        ? CachedNetworkImage(
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            imageUrl: photoUrl,
            imageBuilder: (context, imageProvider) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageProvider,
              ),
            ),
          )
        : Container(
            width: 120,
            height: 120,
            color: Colors.red,
          );
  }
}
