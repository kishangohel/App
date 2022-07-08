import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

class AccountPhoneFormField extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final PhoneController phoneController;
  final Color textColor;
  final void Function(PhoneNumber? number) onChanged;
  final void Function(PhoneNumber number) onSaved;
  const AccountPhoneFormField({
    required this.formKey,
    required this.phoneController,
    required this.textColor,
    required this.onChanged,
    required this.onSaved,
  });
  @override
  State<StatefulWidget> createState() => _AccountPhoneFormFieldState();
}

class _AccountPhoneFormFieldState extends State<AccountPhoneFormField> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: PhoneFormField(
        controller: widget.phoneController,
        flagSize: 18.0,
        countrySelectorNavigator: CountrySelectorNavigator.modalBottomSheet(
          height: MediaQuery.of(context).size.height * 0.7,
        ),
        countryCodeStyle: TextStyle(
          color: widget.textColor,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
        style: TextStyle(
          color: widget.textColor,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          errorStyle: Theme.of(context).textTheme.headline6?.copyWith(
                color: widget.textColor,
                fontWeight: FontWeight.w600,
              ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.textColor,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.textColor,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.textColor,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.textColor,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.textColor,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        validator: PhoneValidator.validMobile(),
        autovalidateMode: AutovalidateMode.always,
        onChanged: widget.onChanged,
        onSaved: (phoneNumber) {
          assert(phoneNumber != null);
          widget.onSaved(phoneNumber!);
        },
        onSubmitted: (phoneNumber) {
          if (widget.phoneController.value != null &&
              widget.phoneController.value!.validate(
                type: PhoneNumberType.mobile,
              )) {
            widget.formKey.currentState!.save();
          }
        },
      ),
    );
  }
}
