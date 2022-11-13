// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_connect_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletConnectState _$WalletConnectStateFromJson(Map<String, dynamic> json) =>
    WalletConnectState(
      activeWallet: _$JsonConverterFromJson<Map<String, dynamic>, Wallet>(
          json['activeWallet'], const WalletJsonConverter().fromJson),
      status: _$JsonConverterFromJson<Map<String, dynamic>, SessionStatus>(
          json['status'], const SessionStatusJsonConverter().fromJson),
      errorMessage: json['errorMessage'] as String?,
      agreementSigned: json['agreementSigned'] as bool? ?? false,
      cbAccount: json['cbAccount'] == null
          ? null
          : Account.fromJson(json['cbAccount'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WalletConnectStateToJson(WalletConnectState instance) =>
    <String, dynamic>{
      'activeWallet': _$JsonConverterToJson<Map<String, dynamic>, Wallet>(
          instance.activeWallet, const WalletJsonConverter().toJson),
      'status': _$JsonConverterToJson<Map<String, dynamic>, SessionStatus>(
          instance.status, const SessionStatusJsonConverter().toJson),
      'errorMessage': instance.errorMessage,
      'agreementSigned': instance.agreementSigned,
      'cbAccount': instance.cbAccount,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
