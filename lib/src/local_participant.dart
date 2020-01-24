import 'package:enum_to_string/enum_to_string.dart';
import 'package:twilio_unofficial_programmable_video/src/connect_options.dart';
import 'package:twilio_unofficial_programmable_video/src/local_video_track_publication.dart';
import 'package:twilio_unofficial_programmable_video/src/network_quality_level.dart';

class LocalParticipant {
  final String _identity;

  final String _sid;

  final String _signalingRegion;

  NetworkQualityLevel _networkQualityLevel;

  List<LocalVideoTrackPublication> _localVideoTrackPublications = <LocalVideoTrackPublication>[];

  /// The SID of this [LocalParticipant].
  String get sid {
    return _sid;
  }

  /// The identity of this [LocalParticipant].
  String get identity {
    return _identity;
  }

  /// Where the [LocalParticipant] signalling traffic enters and exits Twilio's communications cloud.
  ///
  /// This property reflects the region passed to [ConnectOptions.region] and when `gll` (the default value) is provided, the region that was selected will use latency based routing.
  String get signalingRegion {
    return _signalingRegion;
  }

  /// The network quality of the [LocalParticipant].
  NetworkQualityLevel get networkQualityLevel {
    return _networkQualityLevel;
  }

  LocalParticipant(this._identity, this._sid, this._signalingRegion)
      : assert(_identity != null),
        assert(_sid != null),
        assert(_signalingRegion != null);

  factory LocalParticipant.fromMap(Map<String, dynamic> map) {
    LocalParticipant localParticipant = LocalParticipant(map['identity'], map['sid'], map['signalingRegion']);
    localParticipant.updateFromMap(map);
    return localParticipant;
  }

  void updateFromMap(Map<String, dynamic> map) {
    _networkQualityLevel = EnumToString.fromString(NetworkQualityLevel.values, map['networkQualityLevel']) ?? NetworkQualityLevel.NETWORK_QUALITY_LEVEL_UNKNOWN;

    if (map['localVideoTrackPublications'] != null) {
      final List<Map<String, dynamic>> localVideoTrackPublicationsList = map['localVideoTrackPublications'].map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r)).toList();
      for (final Map<String, dynamic> localVideoTrackPublicationMap in localVideoTrackPublicationsList) {
        final LocalVideoTrackPublication localVideoTrackPublication = this._localVideoTrackPublications.firstWhere(
              (p) => p.trackSid == localVideoTrackPublicationMap['sid'],
              orElse: () => LocalVideoTrackPublication.fromMap(localVideoTrackPublicationMap),
            );
        if (!this._localVideoTrackPublications.contains(localVideoTrackPublication)) {
          this._localVideoTrackPublications.add(localVideoTrackPublication);
        }
        localVideoTrackPublication.updateFromMap(localVideoTrackPublicationMap);
      }
    }
  }
}
