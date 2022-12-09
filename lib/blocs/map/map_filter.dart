enum MapFilter {
  none,
  excludeProfiles,
  excludeAccessPoints,
  excludeAll;

  static MapFilter parse(String? input) {
    for (final value in values) {
      if (input == value.name) return value;
    }

    return MapFilter.none;
  }

  bool get showAccessPoints =>
      this != MapFilter.excludeAccessPoints && this != MapFilter.excludeAll;

  bool get showProfiles =>
      this != MapFilter.excludeProfiles && this != MapFilter.excludeAll;
}
