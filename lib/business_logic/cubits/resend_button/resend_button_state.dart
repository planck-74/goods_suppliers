import 'package:flutter/material.dart';

abstract class ResendButtonState {}

class resendButtonInitial extends ResendButtonState {}

class resendButtonDisabled extends ResendButtonState {
  final Color color;
  resendButtonDisabled({required this.color});
}

class resendButtonEnabled extends ResendButtonState {
  final Color color;
  resendButtonEnabled({required this.color});
}
