// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      id: json['id'] as String,
      ethAddress: json['ethAddress'] as String?,
      pfp: json['pfp'] as String?,
      pfpType: $enumDecodeNullable(_$PfpTypeEnumMap, json['pfpType']),
      displayName: json['displayName'] as String?,
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'ethAddress': instance.ethAddress,
      'pfp': instance.pfp,
      'pfpType': _$PfpTypeEnumMap[instance.pfpType],
      'displayName': instance.displayName,
    };

const _$PfpTypeEnumMap = {
  PfpType.remoteSvg: 'remoteSvg',
  PfpType.remotePng: 'remotePng',
  PfpType.localSvg: 'localSvg',
  PfpType.localPng: 'localPng',
};
