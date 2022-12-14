import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

class PhoneScreenPhoneFormField extends StatefulWidget {
  final PhoneController phoneController;
  final void Function(PhoneNumber? number) onChanged;
  const PhoneScreenPhoneFormField({
    required this.phoneController,
    required this.onChanged,
  });
  @override
  State<StatefulWidget> createState() => _PhoneScreenPhoneFormFieldState();
}

class _PhoneScreenPhoneFormFieldState extends State<PhoneScreenPhoneFormField> {
  @override
  Widget build(BuildContext context) {
    return PhoneFormField(
      controller: widget.phoneController,
      flagSize: 16.0,
      countrySelectorNavigator: CountrySelectorNavigator.searchDelegate(
        titleStyle: Theme.of(context).textTheme.titleMedium,
        subtitleStyle: Theme.of(context).textTheme.bodyMedium,
      ),
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
    );
  }
}
