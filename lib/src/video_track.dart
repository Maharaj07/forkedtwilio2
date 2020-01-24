abstract class VideoTrack {
  final String _name;

  bool _enabled;

  /// Check if it is enabled.
  bool get isEnabled {
    return _enabled;
  }

  String get name {
    return _name;
  }

  VideoTrack(this._enabled, this._name)
      : assert(_enabled != null),
        assert(_name != null);

  void updateFromMap(Map<String, dynamic> map) {
    _enabled = map['enabled'];
  }
}
