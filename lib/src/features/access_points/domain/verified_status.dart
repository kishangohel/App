enum VerifiedStatus {
  verified,
  unverified,
  expired;

  bool get isVerified => this == VerifiedStatus.verified;

  bool get isUnverified => this == VerifiedStatus.unverified;

  bool get isExpired => this == VerifiedStatus.expired;

  String get label {
    switch (this) {
      case VerifiedStatus.verified:
        return 'VeriFied';
      case VerifiedStatus.unverified:
        return 'UnVeriFied';
      case VerifiedStatus.expired:
        return 'Expired';
    }
  }
}
