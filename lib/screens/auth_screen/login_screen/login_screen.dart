import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/auth_screen/login_screen/forgot_username_or_password_button.dart';
import 'package:verifi/screens/auth_screen/login_screen/login_button.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, loginState) {
        if (loginState.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(loginState.error)),
            );
        } else if (loginState.status.isSubmissionSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          title: Text(
            "Sign In",
            style: Theme.of(context)
                .textTheme
                .headline5
                ?.copyWith(color: Colors.black),
          ),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
          ),
        ),
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              _EmailInput(),
              _PasswordInput(),
              LoginButton(),
              ForgotPasswordButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, loginState) {
        return Container(
          child: TextFormField(
            initialValue: loginState.email.value,
            onChanged: (email) =>
                context.read<LoginCubit>().emailOrUsernameChanged(email),
            decoration: InputDecoration(
              labelText: 'Email',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2.0,
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0,
                ),
              ),
              helperText: '',
              errorText: loginState.email.invalid ? 'invalid email' : null,
            ),
            style: Theme.of(context).textTheme.bodyText2,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, loginState) {
        return Container(
          child: TextFormField(
            initialValue: loginState.password.value,
            onChanged: (password) =>
                context.read<LoginCubit>().passwordChanged(password),
            //obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2.0,
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0,
                ),
              ),
              helperText: '',
              errorText:
                  loginState.password.invalid ? 'invalid password' : null,
            ),
            style: Theme.of(context).textTheme.bodyText2,
          ),
        );
      },
    );
  }
}
