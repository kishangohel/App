import 'package:equatable/equatable.dart';

class IntroPagesState extends Equatable {
  final bool onboarded;

  const IntroPagesState({
    this.onboarded = false,
  });

  @override
  List<Object> get props => [onboarded];

  IntroPagesState copyWith({bool? onboarded}) {
    return IntroPagesState(
      onboarded: onboarded ?? this.onboarded,
    );
  }
}
