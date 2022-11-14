import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? displayName;
  final Timestamp? createdOn;
  final String? ethAddress;
  final GeoPoint? lastLocation;
  final String? pfp;
  final String? encodedPfp;
  final int? veriPoints;

  const UserEntity({
    required this.id,
    this.displayName,
    this.createdOn,
    this.lastLocation,
    this.ethAddress,
    this.pfp,
    this.encodedPfp,
    this.veriPoints,
  });

  @override
  String toString() => 'UserEntity: { ID: "$id", DisplayName: $displayName }';

  @override
  List<Object?> get props => [id];

  factory UserEntity.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return UserEntity(
        id: snapshot.id,
        displayName: data['DisplayName'],
        createdOn: data['CreatedOn'],
        ethAddress: data['EthAddress'],
        pfp: data['PFP'],
        encodedPfp: data['EncodedPfp'],
        veriPoints: data['VeriPoints'],
      );
    } else {
      return UserEntity(id: snapshot.id);
    }
  }
}
