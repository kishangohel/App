import 'package:equatable/equatable.dart';

class Place extends Equatable {
  final String placeId;
  final String name;

  const Place({required this.placeId, required this.name});

  @override
  List<Object?> get props => [placeId];

  @override
  String toString() => name;
}
