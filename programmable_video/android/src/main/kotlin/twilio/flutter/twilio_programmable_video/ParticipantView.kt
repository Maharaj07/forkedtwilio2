package twilio.flutter.twilio_programmable_video

import com.twilio.video.VideoTrack
import com.twilio.video.VideoView
import io.flutter.plugin.platform.PlatformView

class ParticipantView(private var videoView: VideoView, private var videoTrack: VideoTrack) : PlatformView {
    private val TAG = "ParticipantView"

    init {
        debug("init => Initializing ParticipantView")
        videoTrack.addSink(videoView)
    }

    override fun getView(): VideoView {
        return videoView
    }

    override fun dispose() {
        debug("dispose => Disposing ParticipantView")
        videoTrack.removeSink(videoView)
    }

    internal fun debug(msg: String) {
        TwilioProgrammableVideoPlugin.debug("$TAG::$msg")
    }
}
