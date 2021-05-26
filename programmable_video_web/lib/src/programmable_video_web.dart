import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:pedantic/pedantic.dart';
import 'package:programmable_video_web/src/interop/classes/js_map.dart';
import 'package:programmable_video_web/src/interop/classes/room.dart';
import 'package:programmable_video_web/src/interop/connect.dart';
import 'package:programmable_video_web/src/interop/classes/logger.dart';
import 'package:programmable_video_web/src/listeners//RoomEventListener.dart';
import 'package:programmable_video_web/src/listeners/LocalParticipantEventListener.dart';
import 'package:programmable_video_web/src/listeners/RemoteParticipantEventListener.dart';

import 'package:twilio_programmable_video_platform_interface/twilio_programmable_video_platform_interface.dart';

class ProgrammableVideoPlugin extends ProgrammableVideoPlatform {
  static Room _room;

  static final _roomStreamController = StreamController<BaseRoomEvent>.broadcast();
  // TODO add listeners for camera stream
  static final _cameraStreamController = StreamController<BaseCameraEvent>.broadcast();
  static final _localParticipantController = StreamController<BaseLocalParticipantEvent>.broadcast();
  static final _remoteParticipantController = StreamController<BaseRemoteParticipantEvent>.broadcast();
  static final _loggingStreamController = StreamController<String>.broadcast();

  static var _nativeDebug = false;
  static final _registeredRemoteParticipantViewFactories = [];

  static void debug(String msg) {
    if (_nativeDebug) _loggingStreamController.add(msg);
  }

  static void _createLocalViewFactory() {
    ui.platformViewRegistry.registerViewFactory('local-video-track-html', (int viewId) {
      final localVideoTrackElement = _room.localParticipant.videoTracks.values().next().value.track.attach()..style.objectFit = 'cover';
      debug('Created local video view factory for:  ${_room.localParticipant.sid}');
      return localVideoTrackElement;
    });
  }

  static void _createRemoteViewFactory(String remoteParticipantSid, String remoteVideoTrackSid) {
    ui.platformViewRegistry.registerViewFactory('remote-video-track-#$remoteVideoTrackSid-html', (int viewId) {
      final remoteVideoTrackElement = _room.participants.toDartMap()[remoteParticipantSid].videoTracks.toDartMap()[remoteVideoTrackSid].track.attach()..style.objectFit = 'cover';
      debug('Created remote video view factory for: $remoteParticipantSid');
      return remoteVideoTrackElement;
    });
  }

  static void _addPriorRemoteParticipantListeners(){
    final remoteParticipants = _room.participants.values();
    var current = remoteParticipants.next();
    while(!current.done){
      final remoteParticipantListener = RemoteParticipantEventListener(current.value, _remoteParticipantController);
      remoteParticipantListener.addListeners();
      current = remoteParticipants.next();
    }
  }

  static void registerWith(Registrar registrar) {
    ProgrammableVideoPlatform.instance = ProgrammableVideoPlugin();
    _createLocalViewFactory();
  }

  //#region Functions
  @override
  Widget createLocalVideoTrackWidget({bool mirror = true, Key key}) {
    if (_room == null) {
      return null;
    }
    debug('Created local video track widget for: ${_room.localParticipant.sid}');
    return HtmlElementView(viewType: 'local-video-track-html', key: key);
  }

  @override
  Widget createRemoteVideoTrackWidget({
    String remoteParticipantSid,
    String remoteVideoTrackSid,
    bool mirror = true,
    Key key,
  }) {
    if (!_registeredRemoteParticipantViewFactories.contains(remoteParticipantSid)) {
      _createRemoteViewFactory(remoteParticipantSid, remoteVideoTrackSid);
      _registeredRemoteParticipantViewFactories.add(remoteParticipantSid);
    }
    debug('Created remote video track widget for: $remoteParticipantSid');
    return HtmlElementView(viewType: 'remote-video-track-#$remoteVideoTrackSid-html');

  }

  @override
  Future<int> connectToRoom(ConnectOptionsModel connectOptions) async {
    unawaited(
      connectWithModel(connectOptions).then((room) {
        _room = room;
        final _roomModel = Connected(_room.toModel());
        _roomStreamController.add(_roomModel);
        debug('Connecting to room: ${_room.name}');

        final roomListener = RoomEventListener(_room, _roomStreamController, _remoteParticipantController);
        roomListener.addListeners();
        final localParticipantListener = LocalParticipantEventListener(_room.localParticipant, _localParticipantController);
        localParticipantListener.addListeners();
        _addPriorRemoteParticipantListeners();

      }),
    );

    return 0;
  }

  @override
  Future<void> disconnect() async {
    debug('Disconnecting to room: ${_room.name}');
    _room?.disconnect();
  }

  @override
  Future<bool> enableAudioTrack({bool enable, String name}) {
    final localAudioTracks = _room?.localParticipant?.audioTracks?.values();
    var current = localAudioTracks.next();

    while (!current.done) {
      if (current?.value?.trackName == name) {
        enable ? current?.value?.track?.enable() : current?.value?.track?.disable();
        break;
      }
      current = localAudioTracks.next();
    }
    debug('${enable ? 'Enabled' : 'Disabled'} Local Audio Track');

    return Future(() => enable);
  }

  @override
  Future<bool> enableVideoTrack({bool enabled, String name}) {
    final localVideoTracks = _room?.localParticipant?.videoTracks?.values();
    var current = localVideoTracks.next();

    while (!current.done) {
      if (current?.value?.trackName == name) {
        enabled ? current?.value?.track?.enable() : current?.value?.track?.disable();
        break;
      }
      current = localVideoTracks.next();
    }
    debug('${enabled ? 'Enabled' : 'Disabled'} Local Video Track');

    return Future(() => enabled);
  }

  @override
  Future<void> setNativeDebug(bool native) async {
    // Currently also enabling SDK debugging when native is true
    if (native && !_nativeDebug) {
      final logger = Logger.getLogger('twilio-video');
      final originalFactory = logger.methodFactory;
      logger.methodFactory = allowInterop((methodName, logLevel, loggerName) {
        var method = originalFactory(methodName, logLevel, loggerName);
        return allowInterop((datetime, logLevel, component, message, [data='',misc='']){
          var output = '[  WEBSDK  ] $datetime $logLevel $component $message $data';
          method(output,datetime, logLevel, component, message, data);
        });
      });
      // Can set to 'debug' for more detail.
      logger.setLevel('info');
    }
    _nativeDebug = native;
  }

  @override
  Future<bool> setSpeakerphoneOn(bool on) {
    return Future(() => true);
  }

  @override
  Future<bool> getSpeakerphoneOn() {
    return Future(() => true);
  }

  @override
  Future<CameraSource> switchCamera() {
    return Future(() => CameraSource.FRONT_CAMERA);
  }

  @override
  Future<bool> hasTorch() async {
    return Future(() => false);
  }

  @override
  Future<void> setTorch(bool enabled) async {}

  @override
  Future<void> sendMessage({String message, String name}) {
    return Future(() {});
  }

  @override
  Future<void> sendBuffer({ByteBuffer message, String name}) {
    return Future(() {});
  }

  @override
  Future<void> enableRemoteAudioTrack({bool enable, String sid}) {
    return Future(() {});
  }

  @override
  Future<bool> isRemoteAudioTrackPlaybackEnabled(String sid) {
    return Future(() => false);
  }

  //#endregion

  //#region Streams
  @override
  Stream<BaseCameraEvent> cameraStream() {
    return _cameraStreamController.stream;
  }

  @override
  Stream<BaseRoomEvent> roomStream(int internalId) {
    return _roomStreamController.stream;
  }

  @override
  Stream<BaseRemoteParticipantEvent> remoteParticipantStream(int internalId) {
    return _remoteParticipantController.stream;
  }

  @override
  Stream<BaseLocalParticipantEvent> localParticipantStream(int internalId) {
    return _localParticipantController.stream;
  }

  @override
  Stream<BaseRemoteDataTrackEvent> remoteDataTrackStream(int internalId) {
    return Stream.empty();
  }

  @override
  Stream<dynamic> loggingStream() {
    return _loggingStreamController.stream;
  }
//#endregion
}
