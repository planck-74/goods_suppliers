import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/resend_button/resend_button_state.dart';

class ResendButtonCubit extends Cubit<ResendButtonState> {
  ResendButtonCubit() : super(resendButtonInitial());

  void setResendButtonEnabled(Color color) {
    emit(resendButtonEnabled(color: color));
  }

  void setResendButtonDisabled(Color color) {
    emit(resendButtonDisabled(color: color));
  }
}
