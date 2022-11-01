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
        flagSize: 16.0,
        countrySelectorNavigator:
            const CountrySelectorNavigator.modalBottomSheet(),
        countryCodeStyle: Theme.of(context).textTheme.titleMedium,
        style: Theme.of(context).textTheme.titleMedium,
        decoration: InputDecoration(
          errorStyle: Theme.of(context).textTheme.titleSmall,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        validator: PhoneValidator.validMobile(),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: widget.onChanged,
        onSaved: (phoneNumber) {
          assert(phoneNumber != null);
          widget.onSaved(phoneNumber!);
        },
        onSubmitted: (phoneNumber) {
          if (widget.phoneController.value != null &&
              widget.phoneController.value!.isValid(
                type: PhoneNumberType.mobile,
              )) {
            widget.formKey.currentState!.save();
          }
        },
      ),
    );
  }
}
