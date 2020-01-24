class LocalAudioTrack {
  final bool _enable;

  LocalAudioTrack(this._enable) : assert(_enable != null);

  ///
  void enable(bool enable) {

  }

  Map<String, Object> toMap() {
    return <String, Object>{
      'enable': _enable,
    };
  }
}
