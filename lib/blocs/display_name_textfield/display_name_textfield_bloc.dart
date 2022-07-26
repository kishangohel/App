import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:verifi/repositories/repositories.dart';

class DisplayNameTextfieldBloc
    extends Bloc<DisplayNameTextfieldEvent, DisplayNameTextfieldState> {
  final _duration = const Duration(milliseconds: 300);

  final UsersRepository _repository;

  EventTransformer<Event> debounce<Event>(Duration duration) {
    return (events, mapper) => events.debounce(duration).switchMap(mapper);
  }

  DisplayNameTextfieldBloc(this._repository)
      : super(const DisplayNameTextfieldState(null, null)) {
    on<DisplayNameTextfieldUpdated>(
      _displayNameTextfieldUpdated,
      transformer: debounce(_duration),
    );
    on<DisplayNameTextfieldUpdating>(_displayNameTextfieldUpdating);
  }

  void _displayNameTextfieldUpdating(
    DisplayNameTextfieldUpdating event,
    Emitter<DisplayNameTextfieldState> emit,
  ) async {
    emit(const DisplayNameTextfieldState(null, null));
  }

  void _displayNameTextfieldUpdated(
    DisplayNameTextfieldUpdated event,
    Emitter<DisplayNameTextfieldState> emit,
  ) async {
    if (event.displayName == null || event.displayName!.isEmpty) {
      emit(DisplayNameTextfieldState(event.displayName, null));
      return;
    }
    // validate
    final validateErrorText = _validateDisplayName(event.displayName!);
    if (validateErrorText != null) {
      emit(DisplayNameTextfieldState(event.displayName, validateErrorText));
      return;
    }
    final exists = await _repository.checkIfDisplayNameExists(
      event.displayName,
    );
    // check uniqueness
    if (exists) {
      emit(DisplayNameTextfieldState(
        event.displayName,
        "Display name unavailable",
      ));
      return;
    }
    emit(DisplayNameTextfieldState(event.displayName, null));
  }

  String? _validateDisplayName(String name) {
    final re = RegExp(
      r"^(?=[a-zA-Z0-9._]{3,20}$)(?!.*[_.]{2})[^_.].*[^_.]$",
    );
    if (re.hasMatch(name)) {
      return null;
    } else {
      return """Display name must meet the following requirements:
  \u2022  Length between 3 and 20
  \u2022  Only letters, numbers, and underscores
  \u2022  No leading, trailing, or double (__) underscores
""";
    }
  }
}

abstract class DisplayNameTextfieldEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DisplayNameTextfieldUpdating extends DisplayNameTextfieldEvent {}

class DisplayNameTextfieldUpdated extends DisplayNameTextfieldEvent {
  final String? displayName;

  DisplayNameTextfieldUpdated(this.displayName);

  @override
  List<Object?> get props => [displayName];

  @override
  String toString() {
    return 'DisplayNameTextfieldUpdated: { displayName: $displayName }';
  }
}

class DisplayNameTextfieldState extends Equatable {
  final String? displayName;
  final String? errorText;

  const DisplayNameTextfieldState(
    this.displayName,
    this.errorText,
  );

  @override
  List<Object?> get props => [displayName, errorText];

  @override
  String toString() {
    return 'DisplayNameTextfieldState: { displayName: $displayName, '
        'errorText: $errorText }';
  }
}
