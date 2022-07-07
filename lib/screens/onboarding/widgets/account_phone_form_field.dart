import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

class AccountPhoneFormField extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final PhoneController phoneController;
  final void Function(PhoneNumber? number) onChanged;
  final void Function(PhoneNumber number) onSaved;
  const AccountPhoneFormField({
    required this.formKey,
    required this.phoneController,
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
        countryCodeStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
        decoration: InputDecoration(
          errorStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
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
