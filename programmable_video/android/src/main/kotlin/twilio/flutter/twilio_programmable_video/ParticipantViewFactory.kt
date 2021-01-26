package twilio.flutter.twilio_programmable_video

import android.content.Context
import android.widget.FrameLayout
import android.view.Gravity
import com.twilio.video.VideoTrack
import com.twilio.video.VideoView
import com.twilio.video.VideoScaleType
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ParticipantViewFactory(createArgsCodec: MessageCodec<Any>, private val plugin: PluginHandler) : PlatformViewFactory(createArgsCodec) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView? {
        var videoTrack: VideoTrack? = null

        if (args != null) {
            val params = args as Map<String, Any>
            if (params.containsKey("isLocal")) {
                TwilioProgrammableVideoPlugin.debug("ParticipantViewFactory.create => constructing local view")
                val localParticipant = plugin.getLocalParticipant()
                if (localParticipant != null && localParticipant.localVideoTracks != null && localParticipant.localVideoTracks?.size != 0) {
                    videoTrack = localParticipant.localVideoTracks!![0].localVideoTrack
                }
            } else {
                TwilioProgrammableVideoPlugin.debug("ParticipantViewFactory.create => constructing view with params: '${params.values.joinToString(", ")}'")
                if (params.containsKey("remoteParticipantSid") && params.containsKey("remoteVideoTrackSid")) {
                    val remoteParticipant = plugin.getRemoteParticipant(params["remoteParticipantSid"] as String)
                    val remoteVideoTrack = remoteParticipant?.remoteVideoTracks?.find { it.trackSid == params["remoteVideoTrackSid"] }
                    if (remoteParticipant != null && remoteVideoTrack != null) {
                        videoTrack = remoteVideoTrack.remoteVideoTrack
                    }
                }
            }

            if (videoTrack != null) {
                val videoView = VideoView(context)
                val layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    gravity = Gravity.CENTER
                }
                videoView.setLayoutParams(layoutParams)

                val scaleType = this.getScaleTypeFromInt(params["renderMode"] as Int)
                val mirror = params["mirror"] as Boolean

                videoView.mirror = mirror
                videoView.videoScaleType = scaleType

                return ParticipantView(videoView, videoTrack)
            }
        }

        return null
    }

    private fun getScaleTypeFromInt(typeInt: Int): VideoScaleType {
        if (typeInt == 2) {
            return VideoScaleType.ASPECT_FILL
        } else if (typeInt == 1) {
            return VideoScaleType.ASPECT_FIT
        } else {
            return VideoScaleType.ASPECT_BALANCED
        }
    }
}
