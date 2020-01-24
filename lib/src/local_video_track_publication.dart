import 'package:twilio_unofficial_programmable_video/src/remote_video_track.dart';

import '../twilio_unofficial_programmable_video.dart';

class LocalVideoTrackPublication {
  final String _sid;

  LocalVideoTrack _localVideoTrack;

  /// The SID of the local video track.
  String get trackSid {
    return _sid;
  }

  /// The name of the local video track.
  String get trackName {
    return _localVideoTrack.name;
  }

  /// Returns `true` if the published video track is enabled or `false` otherwise.
  bool get isTrackEnabled {
    return _localVideoTrack.isEnabled;
  }

  /// The local video track.
  LocalVideoTrack get localVideoTrack {
    return _localVideoTrack;
  }

  LocalVideoTrackPublication(this._sid)
      : assert(_sid != null);

  factory LocalVideoTrackPublication.fromMap(Map<String, dynamic> map) {
    LocalVideoTrackPublication localVideoTrackPublication = LocalVideoTrackPublication(map["sid"]);
    localVideoTrackPublication.updateFromMap(map);
    return localVideoTrackPublication;
  }

  void updateFromMap(Map<String, dynamic> map) {
    if (map['localVideoTrack'] != null) {
      final Map<String, dynamic> localVideoTrackMap = Map<String, dynamic>.from(map['localVideoTrack']);
      if (_localVideoTrack == null) {
        _localVideoTrack = LocalVideoTrack.fromMap(localVideoTrackMap);
      } else {
        _localVideoTrack.updateFromMap(localVideoTrackMap);
      }
    }
  }
}
