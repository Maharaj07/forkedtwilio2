/// Video display mode.
enum VideoRenderMode {
  /// Uniformly scale the video until it fills the visible boundaries (cropped). One dimension of the video may have clipped contents.
  Fill,

  /// Uniformly scale the video until one of its dimension fits the boundary (zoomed to fit). Areas that are not filled due to the disparity in the aspect ratio are filled with black.
  Fit,

  /// The fill mode. In this mode, the SDK stretches or zooms the video to fill the display window.
  Hidden,
}
