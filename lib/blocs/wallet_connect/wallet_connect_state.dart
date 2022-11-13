import 'package:coinbase_wallet_sdk/account.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:verifi/models/wallet.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

part 'wallet_connect_state.g.dart';

@JsonSerializable()
class WalletConnectState extends Equatable {
  @WalletJsonConverter()
  final Wallet? activeWallet;
  @SessionStatusJsonConverter()
  final SessionStatus? status;
  final String? errorMessage;
  final bool agreementSigned;
  // Coinbase only
  final Account? cbAccount;

  const WalletConnectState({
    this.activeWallet,
    this.status,
    this.errorMessage,
    this.agreementSigned = false,
    this.cbAccount,
  });

  @override
  List<Object?> get props => [
        activeWallet,
        status,
        errorMessage,
        agreementSigned,
        cbAccount,
      ];

  WalletConnectState copyWith({
    SessionStatus? status,
    Wallet? activeWallet,
    String? errorMessage,
    bool? agreementSigned,
    Account? cbAccount,
  }) {
    return WalletConnectState(
      activeWallet: activeWallet ?? this.activeWallet,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      agreementSigned: agreementSigned ?? this.agreementSigned,
      cbAccount: cbAccount ?? this.cbAccount,
    );
  }

  @override
  String toString() {
    return 'WalletConnectState : { '
        'activeWallet: $activeWallet, '
        'status: $status, '
        'errorMessage: $errorMessage, '
        'agreementSigned: $agreementSigned, '
        'cbAccount: $cbAccount }';
  }

  factory WalletConnectState.fromJson(Map<String, dynamic> json) =>
      _$WalletConnectStateFromJson(json);

  Map<String, dynamic> toJson() => _$WalletConnectStateToJson(this);
}

class WalletJsonConverter extends JsonConverter<Wallet, Map<String, dynamic>> {
  const WalletJsonConverter();
  @override
  Wallet fromJson(Map<String, dynamic> json) => Wallet(
        name: json["name"],
        domain: json["domain"],
        scheme: json["scheme"],
        logo: json["logo"],
      );

  @override
  Map<String, dynamic> toJson(Wallet object) => {
        "name": object.name,
        "logo": object.logo,
        "scheme": object.scheme,
        "domain": object.domain,
      };
}

class SessionStatusJsonConverter
    extends JsonConverter<SessionStatus, Map<String, dynamic>> {
  const SessionStatusJsonConverter();
  @override
  SessionStatus fromJson(Map<String, dynamic> json) => SessionStatus(
        chainId: json["chainId"],
        rpcUrl: json["rpcUrl"],
        accounts: json["accounts"],
        networkId: json["networkId"],
      );

  @override
  Map<String, dynamic> toJson(SessionStatus object) => {
        "chainId": object.chainId,
        "rpcUrl": object.rpcUrl,
        "accounts": object.accounts,
        "networkId": object.networkId,
      };
}
