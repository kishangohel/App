import 'package:flutter/material.dart';

class SocialAuthDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white12,
                    Colors.white,
                  ],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 1.0),
                ),
              ),
              height: 1.0,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "OR",
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white12,
                  ],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 1.0),
                  tileMode: TileMode.repeated,
                ),
              ),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
