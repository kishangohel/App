extension MapExtension on Map<String, dynamic> {
  void putIfValueNotNull(String key, dynamic value) {
    if (value != null) {
      putIfAbsent(key, () => value);
    }
  }
}
