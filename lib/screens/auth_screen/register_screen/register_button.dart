import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:verifi/blocs/blocs.dart';

class RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(builder: (context, registerState) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Visibility(
          visible: !(registerState.status.isPure || registerState.status.isInvalid),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 48.0,
                vertical: 6.0,
              ),
              primary: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
            onPressed: () {
              if (registerState.status.isSubmissionInProgress) {
                return;
              }
              FocusScope.of(context).unfocus();
              context.read<RegisterCubit>().signUp();
            },
            child: (registerState.status == FormzStatus.submissionInProgress)
                ? Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  )
                : Text(
                    'Sign Up',
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                  ),
          ),
        ),
      );
    });
  }
}
