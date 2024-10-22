part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

const bool alsoVideo = false;

class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;

  @override
  void initState() {
    super.initState();

    availableCameras().then((cameras) {
      if (cameras.length > 0) {
        controller = CameraController(cameras[0], ResolutionPreset.max);
        controller!.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        }).catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                // Handle access errors here.
                break;
              default:
                // Handle other errors here.
                break;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return SmashCircularProgress();
    }
    return CameraPreview(controller!);
  }
}

class CameraScreen extends StatefulWidget {
  Function? onCameraFileFunction;
  CameraScreen({this.onCameraFileFunction, Key? key}) : super(key: key);
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  ResolutionPreset _resolutionPreset = ResolutionPreset.medium;
  Orientation? currentOrientation;

  @override
  void initState() {
    String value = GpPreferences().getStringSync(
            SmashPreferencesKeys.KEY_CAMERA_RESOLUTION,
            CameraResolutions.MEDIUM) ??
        CameraResolutions.MEDIUM;
    if (value == CameraResolutions.LOW) {
      _resolutionPreset = ResolutionPreset.medium;
    } else if (value == CameraResolutions.MEDIUM) {
      _resolutionPreset = ResolutionPreset.veryHigh;
    } else if (value == CameraResolutions.HIGH) {
      _resolutionPreset = ResolutionPreset.max;
    }

    super.initState();
    WidgetsBinding.instance.addObserver(this); // Listen to app lifecycle

    // _initializeCamera();
  }

  @override
  void dispose() {
    // Dispose of the camera controller when the widget is disposed.
    if (_controller != null) _controller!.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WidgetsBinding.instance.removeObserver(this); // Remove observer
    // Reset the preferred orientations when leaving
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Detect orientation changes and update the UI
    final newOrientation = MediaQuery.of(context).orientation;
    SystemChrome.setPreferredOrientations([
      newOrientation == Orientation.portrait
          ? DeviceOrientation.portraitUp
          : DeviceOrientation.landscapeLeft,
    ]);

    // if (newOrientation != currentOrientation) {
    //   setState(() {
    //     currentOrientation = newOrientation;
    //   });
    //   // _controller.setRotation(newOrientation == Orientation.portrait ? 0 : 90); // Update camera rotation
    // }

    setState(() {});
  }

  // void _initializeCamera() async {
  //   CameraDescription description =
  //       await availableCameras().then((cameras) => cameras[0]);
  //   var controllerTmp = CameraController(description, _resolutionPreset);

  //   await controllerTmp.initialize();
  //   _controller = controllerTmp;
  //   if (!mounted) {
  //     return;
  //   }
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.hasError) {
          return SmashUI.errorWidget(projectSnap.error.toString());
        } else if (projectSnap.connectionState == ConnectionState.none ||
            projectSnap.data == null) {
          return SmashCircularProgress();
        }

        Widget widget = projectSnap.data as Widget;
        return widget;
      },
      future: getWidget(context),
    );
  }

  Future<Widget> getWidget(BuildContext context) async {
    // bool isLandscape = ScreenUtilities.isLandscape(context);
    // SystemChrome.setPreferredOrientations([
    //   isLandscape
    //       ? DeviceOrientation.landscapeLeft
    //       : DeviceOrientation.portraitUp,
    // ]);

    var list = await availableCameras();
    CameraDescription description = list.first;
    _controller = CameraController(description, _resolutionPreset);
    await _controller!.initialize();

    var h = ScreenUtilities.getHeight(context);
    var w = ScreenUtilities.getWidth(context);
    var aspectRatio = w / h;
    return Scaffold(
      body: AspectRatio(
        aspectRatio: aspectRatio,
        child: CameraPreview(_controller!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  void _takePicture() async {
    final path = HU.FileUtilities.joinPaths(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.jpg',
    );
    XFile filePath = await _controller!.takePicture();
    await filePath.saveTo(path);
    if (widget.onCameraFileFunction != null) {
      widget.onCameraFileFunction!(path);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageScreen(imagePath: path),
      ),
    );
  }
}

class ImageScreen extends StatelessWidget {
  final String imagePath;

  ImageScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.file(File(imagePath)),
    );
  }
}

/// Camera related functions.
// class Camera {
//   /// Take a picture and save it to a file. Then run an optional [onCameraFileFunction] function on it.
//   static Future<String?> takePicture(
//       {Function? onCameraFileFunction, int? imageQuality}) async {
//     final picker = ImagePicker();
//     var imageFile = await picker.pickImage(
//         source: ImageSource.camera, imageQuality: imageQuality);
//     if (imageFile == null) {
//       return null;
//     }
//     if (onCameraFileFunction != null) {
//       onCameraFileFunction(imageFile.path);
//     }
//     return imageFile.path;
//   }

//   /// Load an image from the gallery. Then run an optional [onCameraFileFunction] function on it.
//   static Future<String?> loadImageFromGallery(
//       {Function? onCameraFileFunction}) async {
//     final picker = ImagePicker();
//     var imageFile = await picker.pickImage(source: ImageSource.gallery);
//     if (imageFile == null) {
//       return null;
//     }
//     if (onCameraFileFunction != null) {
//       onCameraFileFunction(imageFile.path);
//     }
//     return imageFile.path;
//   }
// }

// class TakePictureWidget extends StatefulWidget {
//   final String _text;
//   final Function _futureFunction;

//   TakePictureWidget(this._text, this._futureFunction);

//   @override
//   TakePictureWidgetState createState() => TakePictureWidgetState();
// }

// class TakePictureWidgetState extends State<TakePictureWidget> {
//   bool _isDone = false;

//   initState() {
//     run();
//     super.initState();
//   }

//   run() async {
//     var imagePath = await Camera.takePicture();
//     if (imagePath != null) {
//       await widget._futureFunction(imagePath);
//     }
//     setState(() {
//       _isDone = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isDone) {
//       Timer.run(() async {
//         Navigator.of(context).pop();
//       });
//     }
//     return Container(
//       color: SmashColors.mainBackground,
//       padding: SmashUI.defaultPadding(),
//       child: !_isDone
//           ? Center(
//               child: Padding(
//               padding: SmashUI.defaultPadding(),
//               child: SmashCircularProgress(
//                 label: widget._text,
//               ),
//             ))
//           : Center(
//               child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
//                 SmashUI.normalText(widget._text,
//                     color: SmashColors.mainDecorations, bold: true),
//                 Padding(
//                   padding: SmashUI.defaultPadding(),
//                   child: SmashCircularProgress(),
//                 )
//               ]),
//             ),
//     );
//   }
// }
