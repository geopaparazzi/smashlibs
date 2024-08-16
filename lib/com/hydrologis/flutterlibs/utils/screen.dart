part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

/// The screentypes by name/size.
///
/// Taken from Bootstrap docs.
enum ScreenType {
  XS_MOBILE_PORTRAIT,
  SM_MOBILE_LANDSCAPE,
  MD_TABLET_PORTRAIT,
  LG_TABLET_LANDSCAPE,
  XL_MONITOR,
}

/// Class to handle screen issues, like size and orientation
class ScreenUtilities {
  ScreenType getScreenType(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (width < 567) {
      return ScreenType.XS_MOBILE_PORTRAIT;
    } else if (width < 768) {
      return ScreenType.SM_MOBILE_LANDSCAPE;
    } else if (width < 992) {
      return ScreenType.MD_TABLET_PORTRAIT;
    } else if (width < 1200) {
      return ScreenType.LG_TABLET_LANDSCAPE;
    } else {
      return ScreenType.XL_MONITOR;
    }
  }

  /// Check if the screen is in large width mode, i.e. tablet or phone landscape
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if the device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if the device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static void keepScreenOn(bool keepOn) {
    if (!SmashPlatform.isDesktop()) {
      WakelockPlus.toggle(enable: keepOn);
    }
  }
}
