import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/auth_screen/register_screen/register_button.dart';
import 'package:verifi/screens/auth_screen/register_screen/user_agreement_row.dart';
import 'package:formz/formz.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, registerState) {
        if (registerState.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(registerState.error)),
            );
        } else if (registerState.status.isSubmissionSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          title: Text(
            "Create Your Account",
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
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _EmailInput(),
                _PasswordInput(),
                UserAgreementRow(),
                RegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, registerState) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            initialValue: registerState.email.value,
            onChanged: (email) =>
                context.read<RegisterCubit>().emailChanged(email),
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
              errorText: registerState.email.invalid ? 'invalid email' : null,
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
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, registerState) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            initialValue: registerState.password.value,
            onChanged: (password) =>
                context.read<RegisterCubit>().passwordChanged(password),
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
                  registerState.password.invalid ? 'invalid password' : null,
            ),
            style: Theme.of(context).textTheme.bodyText2,
          ),
        );
      },
    );
  }
}
