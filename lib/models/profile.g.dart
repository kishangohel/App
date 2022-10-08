// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      id: json['id'] as String,
      ethAddress: json['ethAddress'] as String?,
      pfp: json['pfp'] == null
          ? null
          : Nft.fromJson(json['pfp'] as Map<String, dynamic>),
      displayName: json['displayName'] as String?,
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'ethAddress': instance.ethAddress,
      'pfp': instance.pfp,
      'displayName': instance.displayName,
    };
