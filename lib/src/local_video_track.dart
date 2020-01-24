import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:twilio_unofficial_programmable_video/src/video_track.dart';

enum CameraSource { FRONT_CAMERA, BACK_CAMERA }

class LocalVideoTrack extends VideoTrack {
  bool _enabled;

  Widget _widget;

  final CameraSource _cameraSource;

  /// Check if it is enabled.
  ///
  /// When the value is `false`, blank video frames are sent. When the value is `true`, frames from the [cameraSource] are provided.
  @override
  bool get isEnabled {
    return _enabled;
  }

  /// Retrieves the [CameraSource].
  CameraSource get cameraSource {
    return _cameraSource;
  }

  LocalVideoTrack(this._enabled, this._cameraSource, {String name = ''})
      : assert(_cameraSource != null),
        super(_enabled, name);

  factory LocalVideoTrack.fromMap(Map<String, dynamic> map) {
    var localVideoTrack = LocalVideoTrack(map['enabled'], CameraSource.FRONT_CAMERA, name: map['name']); // TODO(WLFN): The video capturuer is hardcoded here, should be dynamic from the native side.
    localVideoTrack.updateFromMap(map);
    return localVideoTrack;
  }

  Future<bool> enable(bool enabled) async {
    _enabled = enabled;
    return const MethodChannel('twilio_unofficial_programmable_video').invokeMethod('LocalVideoTrack#enable', <String, dynamic>{'name': name, 'enable': enabled});
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
    return <String, Object>{'enable': isEnabled, 'name': name, 'cameraSource': EnumToString.parse(_cameraSource)};
  }
}
