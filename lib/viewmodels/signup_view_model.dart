import 'package:flutter/material.dart';

class SignUpViewModel {
  final bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool isInputsValid({required GlobalKey<FormState> formKey}) {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return false;
    }

    return true;
  }
}
