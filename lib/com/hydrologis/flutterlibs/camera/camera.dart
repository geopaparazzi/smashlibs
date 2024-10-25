part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

const bool alsoVideo = false;

/// Camera related functions.
class Camera {
  /// Take a picture and save it to a file. Then run an optional [onCameraFileFunction] function on it.
  static Future<String?> takePicture(
      {Function? onCameraFileFunction, int? imageQuality}) async {
    final picker = ImagePicker();
    var imageFile = await picker.pickImage(
        source: ImageSource.camera, imageQuality: imageQuality);
    if (imageFile == null) {
      return null;
    }
    if (onCameraFileFunction != null) {
      onCameraFileFunction(imageFile.path);
    }
    return imageFile.path;
  }

  /// Load an image from the gallery. Then run an optional [onCameraFileFunction] function on it.
  static Future<String?> loadImageFromGallery(
      {Function? onCameraFileFunction}) async {
    final picker = ImagePicker();
    var imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) {
      return null;
    }
    if (onCameraFileFunction != null) {
      onCameraFileFunction(imageFile.path);
    }
    return imageFile.path;
  }
}

class TakePictureWidget extends StatefulWidget {
  final String _text;
  final Function _futureFunction;

  TakePictureWidget(this._text, this._futureFunction);

  @override
  TakePictureWidgetState createState() => TakePictureWidgetState();
}

class TakePictureWidgetState extends State<TakePictureWidget> {
  bool _isDone = false;

  initState() {
    run();
    super.initState();
  }

  run() async {
    var imagePath = await Camera.takePicture();
    if (imagePath != null) {
      await widget._futureFunction(imagePath);
    }
    setState(() {
      _isDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDone) {
      Timer.run(() async {
        Navigator.of(context).pop();
      });
    }
    return Container(
      color: SmashColors.mainBackground,
      padding: SmashUI.defaultPadding(),
      child: !_isDone
          ? Center(
              child: Padding(
              padding: SmashUI.defaultPadding(),
              child: SmashCircularProgress(
                label: widget._text,
              ),
            ))
          : Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                SmashUI.normalText(widget._text,
                    color: SmashColors.mainDecorations, bold: true),
                Padding(
                  padding: SmashUI.defaultPadding(),
                  child: SmashCircularProgress(),
                )
              ]),
            ),
    );
  }
}
