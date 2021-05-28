import 'dart:async';
import 'dart:html';

import 'package:dartlin/control_flow.dart';
import 'package:js/js.dart';
import 'package:programmable_video_web/src/interop/classes/remote_audio_track.dart';
import 'package:programmable_video_web/src/interop/classes/remote_audio_track_publication.dart';
import 'package:programmable_video_web/src/interop/classes/remote_data_track.dart';
import 'package:programmable_video_web/src/interop/classes/remote_data_track_publication.dart';
import 'package:programmable_video_web/src/interop/classes/remote_participant.dart';
import 'package:programmable_video_web/src/interop/classes/remote_track_publication.dart';
import 'package:programmable_video_web/src/interop/classes/remote_video_track.dart';
import 'package:programmable_video_web/src/interop/classes/remote_video_track_publication.dart';
import 'package:programmable_video_web/src/interop/classes/track.dart';
import 'package:programmable_video_web/src/interop/classes/twilio_error.dart';
import 'package:programmable_video_web/src/interop/network_quality_level.dart';
import 'package:programmable_video_web/src/listeners/base_listener.dart';
import 'package:programmable_video_web/src/listeners/remote_data_track_event_listener.dart';
import 'package:twilio_programmable_video_platform_interface/twilio_programmable_video_platform_interface.dart';

class RemoteParticipantEventListener extends BaseListener {
  final RemoteParticipant _remoteParticipant;
  final StreamController<BaseRemoteParticipantEvent> _remoteParticipantController;
  final StreamController<BaseRemoteDataTrackEvent> _remoteDataTrackController;

  RemoteParticipantEventListener(this._remoteParticipant, this._remoteParticipantController, this._remoteDataTrackController);

  @override
  void addListeners() {
    debug('Adding RemoteParticipantEventListeners for ${_remoteParticipant.sid}');
    _onPublication(
      'trackDisabled',
      audioHandler: onTrackDisabledAudio,
      videoHandler: onTrackDisabledVideo,
    );

    _onPublication(
      'trackEnabled',
      audioHandler: onTrackEnabledAudio,
      videoHandler: onTrackEnabledVideo,
    );

    _onPublication(
      'trackPublished',
      audioHandler: onTrackPublishedAudio,
      dataHandler: onTrackPublishedData,
      videoHandler: onTrackPublishedVideo,
    );

    _onPublication(
      'trackUnpublished',
      audioHandler: onTrackUnpublishedAudio,
      dataHandler: onTrackUnpublishedData,
      videoHandler: onTrackPublishedVideo,
    );

    _on('trackSubscribed', onTrackSubscribed);
    _on('trackUnsubscribed', onTrackUnsubscribed);
    _on('trackSubscriptionFailed', onTrackSubscriptionFailed);
    _on('networkQualityLevelChanged', onNetworkQualityLevelChanged);
  }

  void _on(String eventName, Function eventHandler) => _remoteParticipant.on(
        eventName,
        allowInterop(eventHandler),
      );

  void _onPublication(
    String eventName, {
    void Function(RemoteAudioTrackPublication remoteAudioTrackPublication) audioHandler,
    void Function(RemoteDataTrackPublication remoteDataTrackPublication) dataHandler,
    void Function(RemoteVideoTrackPublication remoteVideoTrackPublication) videoHandler,
  }) {
    _on(eventName, (RemoteTrackPublication publication) {
      debug('Added Remote${capitalize(publication.kind)}${capitalize(eventName)} Event');

      when(publication.kind, {
        'audio': () => audioHandler?.call(publication),
        'data': () => dataHandler?.call(publication),
        'video': () => videoHandler?.call(publication),
      });
    });
  }

  void onTrackDisabledAudio(RemoteAudioTrackPublication publication) => _remoteParticipantController.add(RemoteAudioTrackDisabled(
        _remoteParticipant.toModel(),
        publication.toModel(),
      ));

  void onTrackDisabledVideo(RemoteVideoTrackPublication publication) {
    _remoteParticipantController.add(RemoteVideoTrackDisabled(
      _remoteParticipant.toModel(),
      publication.toModel(),
    ));
  }

  void onTrackEnabledAudio(RemoteAudioTrackPublication publication) => _remoteParticipantController.add(
        RemoteAudioTrackEnabled(
          _remoteParticipant.toModel(),
          publication.toModel(),
        ),
      );

  void onTrackEnabledVideo(RemoteVideoTrackPublication publication) => _remoteParticipantController.add(
        RemoteVideoTrackEnabled(
          _remoteParticipant.toModel(),
          publication.toModel(),
        ),
      );

  void onTrackPublishedAudio(RemoteAudioTrackPublication publication) => _remoteParticipantController.add(
        RemoteAudioTrackPublished(
          _remoteParticipant.toModel(),
          publication.toModel(),
        ),
      );

  void onTrackPublishedData(RemoteDataTrackPublication publication) {
    _remoteParticipantController.add(
      RemoteDataTrackPublished(
        _remoteParticipant.toModel(),
        publication.toModel(),
      ),
    );
  }

  void onTrackPublishedVideo(RemoteVideoTrackPublication publication) => _remoteParticipantController.add(
        RemoteVideoTrackPublished(
          _remoteParticipant.toModel(),
          publication.toModel(),
        ),
      );

  void onTrackUnpublishedAudio(RemoteAudioTrackPublication publication) => _remoteParticipantController.add(
        RemoteAudioTrackUnpublished(
          _remoteParticipant.toModel(),
          publication.toModel(),
        ),
      );

  void onTrackUnpublishedData(RemoteDataTrackPublication publication) => _remoteParticipantController.add(
        RemoteDataTrackUnpublished(
          _remoteParticipant.toModel(),
          publication.toModel(),
        ),
      );

  void onTrackUnpublishedVideo(RemoteVideoTrackPublication publication) => _remoteParticipantController.add(
        RemoteVideoTrackUnpublished(
          _remoteParticipant.toModel(),
          publication.toModel(),
        ),
      );

  void onTrackSubscribed(Track track, RemoteTrackPublication publication) {
    debug('Added Remote${capitalize(track.kind)}TrackSubscribed Event');
    when(track.kind, {
      'audio': () {
        final RemoteAudioTrack audioTrack = track;
        final audioElement = audioTrack.attach();
        audioElement.id = track.name;
        document.body.append(audioElement);
        debug('Attached audio element');
        _remoteParticipantController.add(
          RemoteAudioTrackSubscribed(
            remoteParticipantModel: _remoteParticipant.toModel(),
            remoteAudioTrackPublicationModel: (publication as RemoteAudioTrackPublication).toModel(),
            remoteAudioTrackModel: audioTrack.toModel(),
          ),
        );
      },
      'data': () {
        _remoteParticipantController.add(
          RemoteDataTrackSubscribed(
            remoteParticipantModel: _remoteParticipant.toModel(),
            remoteDataTrackPublicationModel: (publication as RemoteDataTrackPublication).toModel(),
            remoteDataTrackModel: (track as RemoteDataTrack).toModel(),
          ),
        );
        final remoteDataTrackListener = RemoteDataTrackEventListener(track as RemoteDataTrack, _remoteDataTrackController);
        remoteDataTrackListener.addListeners();
      },
      'video': () {
        _remoteParticipantController.add(
          RemoteVideoTrackSubscribed(
            remoteParticipantModel: _remoteParticipant.toModel(),
            remoteVideoTrackPublicationModel: (publication as RemoteVideoTrackPublication).toModel(),
            remoteVideoTrackModel: (track as RemoteVideoTrack).toModel(),
          ),
        );
      },
    });
  }

  void onTrackUnsubscribed(Track track, RemoteTrackPublication publication) {
    debug('Added Remote${capitalize(track.kind)}TrackUnsubscribed Event');
    when(track.kind, {
      'audio': () {
        final RemoteAudioTrack audioTrack = track;
        final mediaElements = audioTrack.detach();
        mediaElements.forEach((element) => (element as MediaElement).remove());
        debug('Detached audio element');
        _remoteParticipantController.add(
          RemoteAudioTrackUnsubscribed(
            remoteParticipantModel: _remoteParticipant.toModel(),
            remoteAudioTrackPublicationModel: (publication as RemoteAudioTrackPublication).toModel(),
            remoteAudioTrackModel: (track as RemoteAudioTrack).toModel(),
          ),
        );
      },
      'data': () {
        _remoteParticipantController.add(
          RemoteDataTrackUnsubscribed(
            remoteParticipantModel: _remoteParticipant.toModel(),
            remoteDataTrackPublicationModel: (publication as RemoteDataTrackPublication).toModel(),
            remoteDataTrackModel: (track as RemoteDataTrack).toModel(),
          ),
        );
      },
      'video': () {
        _remoteParticipantController.add(
          RemoteVideoTrackUnsubscribed(
            remoteParticipantModel: _remoteParticipant.toModel(),
            remoteVideoTrackPublicationModel: (publication as RemoteVideoTrackPublication).toModel(),
            remoteVideoTrackModel: (track as RemoteVideoTrack).toModel(),
          ),
        );
      },
    });
  }

  void onTrackSubscriptionFailed(TwilioError error, RemoteTrackPublication publication) {
    debug('Added Remote${capitalize(publication.kind)}TrackSubscriptionFailed Event');

    when(publication.kind, {
      'audio': () {
        _remoteParticipantController.add(
          RemoteAudioTrackSubscriptionFailed(
            remoteParticipantModel: _remoteParticipant.toModel(),
            remoteAudioTrackPublicationModel: (publication as RemoteAudioTrackPublication).toModel(),
            exception: error.toModel(),
          ),
        );
      },
      'data': () {
        _remoteParticipantController.add(
          RemoteDataTrackSubscriptionFailed(
            remoteParticipantModel: _remoteParticipant.toModel(),
            remoteDataTrackPublicationModel: (publication as RemoteDataTrackPublication).toModel(),
            exception: error.toModel(),
          ),
        );
      },
      'video': () {
        _remoteParticipantController.add(
          RemoteVideoTrackSubscriptionFailed(
            remoteParticipantModel: _remoteParticipant.toModel(),
            remoteVideoTrackPublicationModel: (publication as RemoteVideoTrackPublication).toModel(),
            exception: error.toModel(),
          ),
        );
      },
    });
  }

  void onNetworkQualityLevelChanged(int networkQualityLevel, dynamic networkQualityStats) {
    debug('Added RemoteNetworkQualityLevelChanged Event');
    _remoteParticipantController.add(
      RemoteNetworkQualityLevelChanged(
        _remoteParticipant.toModel(),
        networkQualityLevelFromInt(networkQualityLevel),
      ),
    );
  }
}
