import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(builder: (context, registerState) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: 48.0,
              vertical: 6.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
          onPressed: () {
            context.read<LoginCubit>().logInWithCredentials();
          },
          child: Text(
            'Sign In',
            style: Theme.of(context).textTheme.button?.copyWith(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
          ),
        ),
      );
    });
  }
}
