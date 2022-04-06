import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verifi/blocs/register/register_cubit.dart';

class UserAgreementRow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserAgreementRowState();
}

class UserAgreementRowState extends State<UserAgreementRow> {
  bool agreeToUAandPP = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Checkbox(
            value: agreeToUAandPP,
            onChanged: (bool? value) {
              context.read<RegisterCubit>().agreeToUAandPP =
                  !context.read<RegisterCubit>().agreeToUAandPP;
              setState(() => agreeToUAandPP = !agreeToUAandPP);
            },
            activeColor: Theme.of(context).primaryColor,
          ),
          Flexible(
            child: RichText(
              text: TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launch(
                        'https://verifi.world/',
                      ),
                children: [
                  TextSpan(
                    text: "I certify that I agree to the ",
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  TextSpan(
                    text: "User Agreement",
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launch(
                            'https://verifi.world/user-agreement',
                          ),
                  ),
                  TextSpan(
                    text: " and ",
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  TextSpan(
                    text: "Privacy Policy.",
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launch(
                            'https://verifi.world/privacy-policy',
                          ),
                  ),
                ],
                style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      height: 1.2,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
