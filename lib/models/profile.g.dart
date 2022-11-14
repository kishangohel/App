// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      id: json['id'] as String,
      pfp: json['pfp'] == null
          ? null
          : Pfp.fromJson(json['pfp'] as Map<String, dynamic>),
      ethAddress: json['ethAddress'] as String?,
      displayName: json['displayName'] as String?,
      veriPoints: json['veriPoints'] as int?,
      validated: json['validated'] as int?,
      contributed: json['contributed'] as int?,
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'ethAddress': instance.ethAddress,
      'pfp': instance.pfp,
      'displayName': instance.displayName,
      'veriPoints': instance.veriPoints,
      'validated': instance.validated,
      'contributed': instance.contributed,
    };
