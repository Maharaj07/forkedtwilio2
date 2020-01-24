import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twilio_unofficial_programmable_video/src/connect_options.dart';
import 'package:twilio_unofficial_programmable_video/src/room.dart';

class TwilioUnofficialProgrammableVideo {
  static const MethodChannel _methodChannel = MethodChannel('twilio_unofficial_programmable_video');

  static const EventChannel _roomChannel = EventChannel('twilio_unofficial_programmable_video/room');

  static const EventChannel _remoteParticipantChannel = EventChannel('twilio_unofficial_programmable_video/remote');

  static Future<bool> requestPermissionForCameraAndMicrophone() async {
    final permissions = await PermissionHandler().requestPermissions(<PermissionGroup>[PermissionGroup.microphone, PermissionGroup.camera]);

    var cameraAndMicPermissionGranted = true;
    permissions.forEach((PermissionGroup permissionGroup, PermissionStatus permissionStatus) {
      return cameraAndMicPermissionGranted = cameraAndMicPermissionGranted ? permissionStatus == PermissionStatus.granted : false;
    });

    return cameraAndMicPermissionGranted;
  }

  static Future<Room> connect(ConnectOptions connectOptions) async {
    assert(connectOptions != null);

    if (await requestPermissionForCameraAndMicrophone()) {
      final roomId = await _methodChannel.invokeMethod('connect', <String, Object>{'connectOptions': connectOptions.toMap()});

      return Room(roomId, _roomChannel, _remoteParticipantChannel);
    }
    throw Exception('Permissions not granted');
  }
}
