import 'dart:async';

import 'package:js/js.dart';
import 'package:programmable_video_web/src/interop/classes/remote_participant.dart';
import 'package:programmable_video_web/src/interop/classes/room.dart';
import 'package:programmable_video_web/src/interop/classes/twilio_error.dart';
import 'package:programmable_video_web/src/listeners/base_listener.dart';
import 'package:programmable_video_web/src/listeners/remote_participant_event_listener.dart';
import 'package:twilio_programmable_video_platform_interface/twilio_programmable_video_platform_interface.dart';
import 'package:dartlin/dartlin.dart';

class RoomEventListener extends BaseListener {
  final Room _room;
  final StreamController<BaseRoomEvent> _roomStreamController;
  final StreamController<BaseRemoteParticipantEvent> _remoteParticipantController;

  RoomEventListener(this._room, this._roomStreamController, this._remoteParticipantController);

  @override
  void addListeners() {
    debug('Adding RoomEventListeners for ${_room.sid}');
    _on('disconnected', onDisconnected);
    _on('dominantSpeakerChanged', onDominantSpeakerChanged);
    _on('participantConnected', onParticipantConnected);
    _on('participantDisconnected', onParticipantDisconnected);
    _on('reconnected', onReconnected);
    _on('reconnecting', onReconnecting);
    _on('recordingStarted', onRecordingStarted);
    _on('recordingStopped', onRecordingStopped);
  }

  void _on(String eventName, Function eventHandler) => _room.on(
        eventName,
        allowInterop(eventHandler),
      );

  void onDisconnected(Room room, TwilioError error) {
    _roomStreamController.add(Disconnected(room.toModel(), error.let((it) => it.toModel())));
    debug('Added Disconnected Room Event');
  }

  void onDominantSpeakerChanged(RemoteParticipant dominantSpeaker) {
    _roomStreamController.add(DominantSpeakerChanged(_room.toModel(), dominantSpeaker.toModel()));
    debug('Added DominantSpeakerChanged Room Event');
  }

  void onParticipantConnected(RemoteParticipant participant) {
    _roomStreamController.add(ParticipantConnected(_room.toModel(), participant.toModel()));
    debug('Added ParticipantConnected Room Event');

    final remoteParticipantListener = RemoteParticipantEventListener(participant, _remoteParticipantController);
    remoteParticipantListener.addListeners();
  }

  void onParticipantDisconnected(RemoteParticipant participant) {
    _roomStreamController.add(
      ParticipantDisconnected(_room.toModel(), participant.toModel()),
    );
    debug('Added ParticipantDisconnected Room Event');
  }

  void onReconnected() {
    _roomStreamController.add(Reconnected(_room.toModel()));
    debug('Added Reconnected Room Event');
  }

  void onReconnecting(TwilioError error) {
    _roomStreamController.add(Reconnecting(_room.toModel(), error.toModel()));
    debug('Added Reconnecting Room Event');
  }

  void onRecordingStarted() {
    _roomStreamController.add(RecordingStarted(_room.toModel()));
    debug('Added RecordingStarted Room Event');
  }

  void onRecordingStopped() {
    _roomStreamController.add(RecordingStopped(_room.toModel()));
    debug('Added RecordingStopped Room Event');
  }
}
