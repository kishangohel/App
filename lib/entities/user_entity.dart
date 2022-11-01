import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String displayName;
  final Timestamp createdOn;
  final String? ethAddress;
  final GeoPoint? lastLocation;
  final String? pfp;
  final String? encodedPfp;

  const UserEntity({
    required this.id,
    required this.displayName,
    required this.createdOn,
    this.lastLocation,
    this.ethAddress,
    this.pfp,
    this.encodedPfp,
  });

  @override
  String toString() => 'UserEntity: { id: "$id", displayName: $displayName }';

  @override
  List<Object?> get props => [id];

  factory UserEntity.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map;
    return UserEntity(
      id: snapshot.id,
      displayName: data['displayName'],
      createdOn: data['createdOn'],
      ethAddress: data['ethAddress'],
      pfp: data['pfp'],
      encodedPfp: data['encodedPfp'],
    );
  }
}
