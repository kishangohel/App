import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:verifi/blocs/intro_pages/intro_pages_state.dart';

class IntroPagesCubit extends HydratedCubit<IntroPagesState> {
  IntroPagesCubit()
      : super(const IntroPagesState(
          onboarded: false,
        ));

  void setOnboardingComplete() {
    emit(state.copyWith(onboarded: true));
  }

  @override
  IntroPagesState fromJson(Map<String, dynamic> json) {
    return IntroPagesState(onboarded: json['onboarded'] ?? false);
  }

  @override
  Map<String, dynamic> toJson(IntroPagesState state) => {
        'onboarded': state.onboarded,
      };
}
