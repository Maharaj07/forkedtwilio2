import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:twilio_unofficial_programmable_video/src/video_track.dart';

enum VideoCapturer { FRONT_CAMERA, BACK_CAMERA }

class LocalVideoTrack extends VideoTrack {
  Widget _widget;

  final VideoCapturer _videoCapturer;

  /// Check if it is enabled.
  ///
  /// When the value is `false`, blank video frames are sent. When the value is `true`, frames from the [videoCapturer] are provided.
  bool get isEnabled {
    return super.isEnabled;
  }

  /// Retrieves the [VideoCapturer].
  VideoCapturer get videoCapturer {
    return _videoCapturer;
  }

  LocalVideoTrack(_enabled, this._videoCapturer, {String name = ""})
      : assert(_videoCapturer != null),
        super(_enabled, name);

  factory LocalVideoTrack.fromMap(Map<String, dynamic> map) {
    LocalVideoTrack localVideoTrack = LocalVideoTrack(map['enabled'], VideoCapturer.FRONT_CAMERA, name: map['name']); // TODO(WLFN): The video capturuer is hardcoded here, should be dynamic from the native side.
    localVideoTrack.updateFromMap(map);
    return localVideoTrack;
  }

  /// Returns a native widget.
  ///
  /// By default the widget will be mirrored, to change that set [mirror] to false.
  Widget widget({bool mirror = true}) {
    return _widget ??= AndroidView(
      viewType: 'twilio_unofficial_programmable_video/views',
      creationParams: <String, dynamic>{'isLocal': true, 'mirror': mirror},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  Map<String, Object> toMap() {
    return <String, Object>{'enable': isEnabled, 'name': name, 'videoCapturer': _videoCapturer.toString().split('.')[1]};
  }
}
