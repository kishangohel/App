import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/repositories/repositories.dart';

class ForgotPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "Forgot Password",
          style: Theme.of(context).textTheme.bodyText2?.copyWith(
                color: Theme.of(context).primaryColor,
                decoration: TextDecoration.underline,
                fontSize: 16.0,
              ),
        ),
      ),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          final TextEditingController _controller = TextEditingController();
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  height: 3,
                  color: Colors.grey,
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
                Text(
                  "Forgot Username or Password",
                  style: Theme.of(context).textTheme.headline5,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _passwordResetText(),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextField(
                  autofocus: true,
                  controller: _controller,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0,
                      ),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
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
                    child: Text(
                      "Send email",
                      style: Theme.of(context).textTheme.button?.copyWith(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                    ),
                    onPressed: () {
                      context
                          .read<AuthenticationRepository>()
                          .sendPasswordResetEmail(_controller.value.text);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
    );
  }

  String _passwordResetText() =>
      "If you have a VeriFi account, we will send an email with a password " +
      "reset link.";
}
