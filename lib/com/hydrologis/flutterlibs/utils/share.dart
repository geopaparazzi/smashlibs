part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

class ShareHandler {
  static Future<void> shareText(String text, {String title: ''}) async {
    await SharePlus.instance.share(
      ShareParams(text: text),
    );
  }

  static Future<void> shareImage(String text, var imageData) async {
    Directory cacheFolder = await Workspace.getCacheFolder();
    var imageName = "smash_tmp_share_${HU.TimeUtilities.DATE_TS_FORMATTER}.jpg";
    var outPath = HU.FileUtilities.joinPaths(cacheFolder.path, imageName);

    HU.FileUtilities.writeBytesToFile(outPath, imageData);

    final params = ShareParams(
      text: imageName,
      files: [XFile(outPath)],
    );
    await SharePlus.instance.share(params);
  }
}
