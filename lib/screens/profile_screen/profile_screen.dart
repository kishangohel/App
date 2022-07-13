import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final photoUrl = context.read<ProfileCubit>().profilePhoto;
    assert(photoUrl != null);
    return Center(
      child: SizedBox(
        height: 200,
        width: 200,
        child: Image.network(photoUrl!),
      ),
    );
  }
}
