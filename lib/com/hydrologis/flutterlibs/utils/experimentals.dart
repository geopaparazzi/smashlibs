part of smashlibs;

/// Enable rotation of map
const EXPERIMENTAL_ROTATION__ENABLED = false;

/// Enable color substitution in raster tiles/images
const EXPERIMENTAL_HIDE_COLOR_RASTER__ENABLED = true;

// class ExceptionsToTrack {
//   /// Cached uses sqfile on Linux which is not supported.
//   static TileProvider getDefaultForOnlineServices() {
//     return CancellableNetworkTileProvider(silenceExceptions: true);
//     // TileProvider tileProvider = NetworkTileProvider();
//     // // if (Platform.isLinux) {
//     // //   tileProvider = NetworkTileProvider();
//     // // }
//     // return tileProvider;
//   }
// }

class SmashSlider extends Slider {
  SmashSlider({
    super.key,
    required super.value,
    required super.onChanged,
    super.onChangeStart,
    super.onChangeEnd,
    super.min = 0.0,
    super.max = 1.0,
    super.divisions,
    super.activeColor,
    super.thumbColor,
  });
}
