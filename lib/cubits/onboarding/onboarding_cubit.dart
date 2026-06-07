import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks the current onboarding slide index (SRS FR-2.2).
class OnboardingCubit extends Cubit<int> {
  OnboardingCubit() : super(0);

  static const int slideCount = 3;

  void setPage(int index) => emit(index);
  bool get isLast => state == slideCount - 1;
}
