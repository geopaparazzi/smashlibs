// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
part of smashlibs;

Future<List<CameraDescription>> getCameras() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    var cameras = await availableCameras();
    // get only first two cameras
    if (cameras.length > 2) {
      cameras = cameras.sublist(0, 2);
    }
    return cameras;
  } on CameraException catch (e) {
    _logError(e.code, e.description);
  }
  return [];
}

/// Camera example home widget.
class AdvancedCameraWidget extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String title;
  FrameProperties? frameProperties;
  bool doScaffold;
  String cameraResolution;

  /// Default Constructor
  AdvancedCameraWidget(this.cameras,
      {super.key,
      this.title = "Take picture",
      this.frameProperties = null,
      this.doScaffold = false,
      this.cameraResolution = CameraResolutions.HIGH});

  @override
  State<AdvancedCameraWidget> createState() {
    return _AdvancedCameraWidgetState();
  }
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _AdvancedCameraWidgetState extends State<AdvancedCameraWidget>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;
  late AnimationController _focusModeControlRowAnimationController;
  late Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );

    onNewCameraSelected(widget.cameras.first);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    if (widget.doScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: buildMainWidget(),
      );
    } else {
      return buildMainWidget();
    }
  }

  Widget buildMainWidget() {
    return Stack(
      children: <Widget>[
        Container(
          // decoration: BoxDecoration(
          //   color: Colors.black,
          //   border: Border.all(
          //     color: controller != null && controller!.value.isRecordingVideo
          //         ? Colors.redAccent
          //         : Colors.grey,
          //     width: 3.0,
          //   ),
          // ),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Center(
              child: _cameraPreviewWidget(),
            ),
          ),
        ),
        // ! TODO
        Align(
          alignment: Alignment.bottomRight,
          child: IntrinsicWidth(child: IntrinsicHeight(child: _controls())),
        ),
        // _modeControlRowWidget(),
        // Padding(
        //   padding: const EdgeInsets.all(5.0),
        //   child: Row(
        //     children: <Widget>[
        //       _cameraTogglesRowWidget(),
        //       _thumbnailWidget(),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _controls() {
    final CameraController? cameraController = controller;
    var isLarge = ScreenUtilities.isLargeScreen(context);
    var iconSize = isLarge ? SmashUI.LARGE_ICON_SIZE : SmashUI.MEDIUM_ICON_SIZE;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(color: SmashColors.mainDecorations, width: 3),
          color: SmashColors.mainBackground.withOpacity(0.7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Tooltip(
              message: "Take or re-take picture",
              child: IconButton(
                icon: Icon(Icons.camera_alt, size: iconSize),
                color: SmashColors.mainDecorations,
                onPressed: cameraController != null &&
                        cameraController.value.isInitialized &&
                        !cameraController.value.isRecordingVideo
                    ? onTakePictureButtonPressed
                    : null,
              ),
            ),
            if (imageFile != null)
              Tooltip(
                message: "Use image",
                child: IconButton(
                  icon: Icon(MdiIcons.check, size: iconSize),
                  color: SmashColors.mainDecorations,
                  onPressed: () {
                    Navigator.of(context).pop(imageFile!.path);
                  },
                ),
              ),
            if (imageFile != null && widget.frameProperties != null)
              Tooltip(
                message: "Use cropped image",
                child: IconButton(
                  icon: Icon(MdiIcons.crop, size: iconSize),
                  color: SmashColors.mainDecorations,
                  onPressed: () {
                    var finalPath = imageFile!.path;
                    var frameProperties = widget.frameProperties;
                    if (frameProperties != null &&
                        frameProperties.ratio != null) {
                      // crop the picture to the defined frame
                      // at the momento we only handle ratio cases
                      var imgFile = File(imageFile!.path);
                      final image = IMG.decodeImage(imgFile.readAsBytesSync());

                      if (image != null) {
                        var imageWidth = image.width;
                        var imageHeight = image.height;
                        var ratio = frameProperties.ratio!;
                        var newWidth = imageHeight * ratio;
                        var newHeight = newWidth / ratio;
                        if (newWidth > imageWidth) {
                          newHeight = imageWidth / ratio;
                          newWidth = newHeight * ratio;
                        }
                        var left = (imageWidth - newWidth) / 2;
                        var top = (imageHeight - newHeight) / 2;

                        // print("Old image size: $imageWidth x $imageHeight");
                        // print(
                        //     "Cropping image to: left: $left, top: $top, width: $newWidth, height: $newHeight");

                        // Crop the image (parameters: x, y, width, height)
                        final croppedImage = IMG.copyCrop(image,
                            x: left.toInt(),
                            y: top.toInt(),
                            width: newWidth.toInt(),
                            height: newHeight.toInt());

                        // Save the cropped image as a new file
                        var finalFile = HU.FileUtilities.getTmpFile("jpg");
                        // print("Saving to cropped image: $finalFile");
                        File(finalFile.path)
                          ..writeAsBytesSync(IMG.encodeJpg(croppedImage),
                              flush: true);
                        finalPath = finalFile.path;
                      }
                    }
                    Navigator.of(context).pop(finalPath);
                  },
                ),
              ),
            Tooltip(
              message: "Cancel",
              child: IconButton(
                icon: Icon(MdiIcons.close, size: iconSize),
                color: SmashColors.mainDecorations,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            if (imageFile != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _thumbnailWidget(),
              ),
          ],
        ),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      Widget finalWidget = LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onTapDown: (TapDownDetails details) =>
                onViewFinderTap(details, constraints),
            child: widget.frameProperties != null
                ? CustomPaint(
                    painter: FramePainter(widget.frameProperties!),
                  )
                : null);
      });
      // if (widget.frameProperties != null) {
      //   finalWidget = CustomPaint(
      //     painter: FramePainter(widget.frameProperties!),
      //   );
      // }
      // var frameWidget =
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview2(
          controller!,
          child: finalWidget,
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (localVideoController == null && imageFile == null)
            Container()
          else
            SizedBox(
              width: 64.0,
              height: 64.0,
              child: (localVideoController == null)
                  ? (
                      // The captured image on the web contains a network-accessible URL
                      // pointing to a location within the browser. It may be displayed
                      // either with Image.network or Image.memory after loading the image
                      // bytes to memory.
                      kIsWeb
                          ? Image.network(imageFile!.path)
                          : Image.file(File(imageFile!.path)))
                  : Container(
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.pink)),
                      child: Center(
                        child: AspectRatio(
                            aspectRatio: localVideoController.value.aspectRatio,
                            child: VideoPlayer(localVideoController)),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  /// Display a bar with buttons to change the flash and exposure modes
  Widget _modeControlRowWidget() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.flash_on),
              color: Colors.blue,
              onPressed: controller != null ? onFlashModeButtonPressed : null,
            ),
            // The exposure and focus mode are currently not supported on the web.
            ...!kIsWeb
                ? <Widget>[
                    IconButton(
                      icon: const Icon(Icons.exposure),
                      color: Colors.blue,
                      onPressed: controller != null
                          ? onExposureModeButtonPressed
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_center_focus),
                      color: Colors.blue,
                      onPressed:
                          controller != null ? onFocusModeButtonPressed : null,
                    )
                  ]
                : <Widget>[],
            IconButton(
              icon: Icon(enableAudio ? Icons.volume_up : Icons.volume_mute),
              color: Colors.blue,
              onPressed: controller != null ? onAudioModeButtonPressed : null,
            ),
            IconButton(
              icon: Icon(controller?.value.isCaptureOrientationLocked ?? false
                  ? Icons.screen_lock_rotation
                  : Icons.screen_rotation),
              color: Colors.blue,
              onPressed: controller != null
                  ? onCaptureOrientationLockButtonPressed
                  : null,
            ),
          ],
        ),
        _flashModeControlRowWidget(),
        _exposureModeControlRowWidget(),
        _focusModeControlRowWidget(),
      ],
    );
  }

  Widget _flashModeControlRowWidget() {
    return SizeTransition(
      sizeFactor: _flashModeControlRowAnimation,
      child: ClipRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.flash_off),
              color: controller?.value.flashMode == FlashMode.off
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.off)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.flash_auto),
              color: controller?.value.flashMode == FlashMode.auto
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.flash_on),
              color: controller?.value.flashMode == FlashMode.always
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.always)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.highlight),
              color: controller?.value.flashMode == FlashMode.torch
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _exposureModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      foregroundColor: controller?.value.exposureMode == ExposureMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      foregroundColor: controller?.value.exposureMode == ExposureMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: ClipRect(
        child: ColoredBox(
          color: Colors.grey.shade50,
          child: Column(
            children: <Widget>[
              const Center(
                child: Text('Exposure Mode'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    style: styleAuto,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) {
                        controller!.setExposurePoint(null);
                        showInSnackBar('Resetting exposure point');
                      }
                    },
                    child: const Text('AUTO'),
                  ),
                  TextButton(
                    style: styleLocked,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.locked)
                        : null,
                    child: const Text('LOCKED'),
                  ),
                  TextButton(
                    style: styleLocked,
                    onPressed: controller != null
                        ? () => controller!.setExposureOffset(0.0)
                        : null,
                    child: const Text('RESET OFFSET'),
                  ),
                ],
              ),
              const Center(
                child: Text('Exposure Offset'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(_minAvailableExposureOffset.toString()),
                  Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    label: _currentExposureOffset.toString(),
                    onChanged: _minAvailableExposureOffset ==
                            _maxAvailableExposureOffset
                        ? null
                        : setExposureOffset,
                  ),
                  Text(_maxAvailableExposureOffset.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _focusModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      foregroundColor: controller?.value.focusMode == FocusMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      foregroundColor: controller?.value.focusMode == FocusMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _focusModeControlRowAnimation,
      child: ClipRect(
        child: ColoredBox(
          color: Colors.grey.shade50,
          child: Column(
            children: <Widget>[
              const Center(
                child: Text('Focus Mode'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    style: styleAuto,
                    onPressed: controller != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) {
                        controller!.setFocusPoint(null);
                      }
                      showInSnackBar('Resetting focus point');
                    },
                    child: const Text('AUTO'),
                  ),
                  TextButton(
                    style: styleLocked,
                    onPressed: controller != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.locked)
                        : null,
                    child: const Text('LOCKED'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: SmashColors.mainDecorations, width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_alt, size: SmashUI.LARGE_ICON_SIZE),
            color: SmashColors.mainDecorations,
            onPressed: cameraController != null &&
                    cameraController.value.isInitialized &&
                    !cameraController.value.isRecordingVideo
                ? onTakePictureButtonPressed
                : null,
          ),
          if (imageFile != null)
            IconButton(
              icon: Icon(MdiIcons.close, size: SmashUI.LARGE_ICON_SIZE),
              color: SmashColors.mainDecorations,
              onPressed: cameraController != null &&
                      cameraController.value.isInitialized &&
                      !cameraController.value.isRecordingVideo
                  ? onTakePictureButtonPressed
                  : null,
            ),
          if (imageFile != null)
            IconButton(
              icon: Icon(MdiIcons.close, size: SmashUI.LARGE_ICON_SIZE),
              color: SmashColors.mainDecorations,
              onPressed: cameraController != null &&
                      cameraController.value.isInitialized &&
                      !cameraController.value.isRecordingVideo
                  ? onTakePictureButtonPressed
                  : null,
            ),
          // IconButton(
          //   icon: const Icon(Icons.videocam),
          //   color: Colors.blue,
          //   onPressed: cameraController != null &&
          //           cameraController.value.isInitialized &&
          //           !cameraController.value.isRecordingVideo
          //       ? onVideoRecordButtonPressed
          //       : null,
          // ),
          // IconButton(
          //   icon: cameraController != null &&
          //           cameraController.value.isRecordingPaused
          //       ? const Icon(Icons.play_arrow)
          //       : const Icon(Icons.pause),
          //   color: Colors.blue,
          //   onPressed: cameraController != null &&
          //           cameraController.value.isInitialized &&
          //           cameraController.value.isRecordingVideo
          //       ? (cameraController.value.isRecordingPaused)
          //           ? onResumeButtonPressed
          //           : onPauseButtonPressed
          //       : null,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.stop),
          //   color: Colors.red,
          //   onPressed: cameraController != null &&
          //           cameraController.value.isInitialized &&
          //           cameraController.value.isRecordingVideo
          //       ? onStopButtonPressed
          //       : null,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.pause_presentation),
          //   color:
          //       cameraController != null && cameraController.value.isPreviewPaused
          //           ? Colors.red
          //           : Colors.blue,
          //   onPressed:
          //       cameraController == null ? null : onPausePreviewButtonPressed,
          // ),
          _thumbnailWidget(),
        ],
      ),
    );
  }

  /// Returns a suitable camera icon for [direction].
  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
      default:
        return Icons.camera;
    }
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    void onChanged(CameraDescription? description) {
      if (description == null) {
        return;
      }

      onNewCameraSelected(description);
    }

    if (widget.cameras.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        showInSnackBar('No camera found.');
      });
      return const Text('None');
    } else {
      for (final CameraDescription cameraDescription in widget.cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: onChanged,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      return controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    ResolutionPreset res = ResolutionPreset.medium;
    switch (widget.cameraResolution) {
      case CameraResolutions.HIGH:
        res = ResolutionPreset.max;
        break;
      case CameraResolutions.LOW:
        res = ResolutionPreset.low;
        break;
      case CameraResolutions.MEDIUM:
      default:
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : res,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb
            ? <Future<Object?>>[
                cameraController.getMinExposureOffset().then(
                    (double value) => _minAvailableExposureOffset = value),
                cameraController
                    .getMaxExposureOffset()
                    .then((double value) => _maxAvailableExposureOffset = value)
              ]
            : <Future<Object?>>[],
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      if (mounted) {
        setState(() {
          imageFile = file;
          videoController?.dispose();
          videoController = null;
        });
        // if (file != null) {
        //   showInSnackBar('Picture saved to ${file.path}');
        // }
      }
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller!.description);
    }
  }

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        _startVideoPlayer();
      }
    });
  }

  Future<void> onPausePreviewButtonPressed() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isPreviewPaused) {
      await cameraController.resumePreview();
    } else {
      await cameraController.pausePreview();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller!.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }

    final VideoPlayerController vController = kIsWeb
        ? VideoPlayerController.networkUrl(Uri.parse(videoFile!.path))
        : VideoPlayerController.file(File(videoFile!.path));

    videoPlayerListener = () {
      if (videoController != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) {
          setState(() {});
        }
        videoController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

// /// CameraApp is the Main Application.
// class CameraApp extends StatelessWidget {
//   /// Default Constructor
//   const CameraApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: CameraExampleHome(),
//     );
//   }
// }

// Future<void> main() async {
//   // Fetch the available cameras before initializing the app.
//   try {
//     WidgetsFlutterBinding.ensureInitialized();
//     _cameras = await availableCameras();
//   } on CameraException catch (e) {
//     _logError(e.code, e.description);
//   }
//   runApp(const CameraApp());
// }

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A widget showing a live camera preview.
class CameraPreview2 extends StatefulWidget {
  /// A widget to overlay on top of the camera preview
  final Widget? child;
  final bool isTablet;

  /// Creates a preview widget for the given camera controller.
  const CameraPreview2(this.controller,
      {this.isTablet = false, super.key, this.child});

  /// The controller for the camera that the preview is shown for.
  final CameraController controller;

  @override
  State<CameraPreview2> createState() => _CameraPreview2State();
}

class _CameraPreview2State extends State<CameraPreview2>
    with WidgetsBindingObserver {
  DeviceOrientation? currentOrientation;
  CameraState? cameraState;
  @override
  void initState() {
    cameraState = Provider.of<CameraState>(context, listen: false);

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    currentOrientation =
        cameraState!.getOrientation(context, setPreferred: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentOrientation =
        cameraState!.getOrientation(context, setPreferred: true);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([]);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.controller.value.isInitialized
        ? ValueListenableBuilder<CameraValue>(
            valueListenable: widget.controller,
            builder: (BuildContext context, Object? value, Widget? child) {
              return AspectRatio(
                aspectRatio: _isLandscape()
                    ? widget.controller.value.aspectRatio
                    : (1 / widget.controller.value.aspectRatio),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    // controller.buildPreview(),
                    _wrapInRotatedBox(child: widget.controller.buildPreview()),
                    child ?? Container(),
                  ],
                ),
              );
            },
            child: widget.child,
          )
        : Container();
  }

  Widget _wrapInRotatedBox({required Widget child}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

    return RotatedBox(
      quarterTurns: _getQuarterTurns(),
      child: child,
    );
  }

  bool _isLandscape() {
    return <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ].contains(_getApplicableOrientation());
  }

  int _getQuarterTurns() {
    final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    int extraRotation = 0; //widget.isTablet ? 1 : 0;
    if (cameraState!.startupOrientation == DeviceOrientation.landscapeLeft ||
        cameraState!.startupOrientation == DeviceOrientation.landscapeRight) {
      extraRotation += 1;
    }
    var currentOrientation = _getApplicableOrientation();
    print('currentOrientation: $currentOrientation' +
        ' startup: ${cameraState!.startupOrientation} + rotation-applied: ${turns[currentOrientation]!} + $extraRotation');

    return turns[currentOrientation]! + extraRotation;
  }

  DeviceOrientation _getApplicableOrientation() {
    return currentOrientation != null
        ? currentOrientation!
        : widget.controller.value.isRecordingVideo
            ? widget.controller.value.recordingOrientation!
            : (widget.controller.value.previewPauseOrientation ??
                widget.controller.value.lockedCaptureOrientation ??
                widget.controller.value.deviceOrientation);
  }
}

class FrameProperties {
  List<double>? frameGeometry;
  double? boxWidth;
  double? boxHeight;
  late Color frameColor;
  double? strokeWidth;
  double? ratio;

  FrameProperties.defineCenteredBox(double width, double height,
      {Color color = Colors.red, double? strokeWidth}) {
    this.frameColor = color;
    this.strokeWidth = width;
    this.boxWidth = width;
    this.boxHeight = height;
    this.strokeWidth = strokeWidth;
  }

  FrameProperties.defineBorders(
      double left, double top, double right, double bottom,
      {Color color = Colors.red, double? strokeWidth})
      : frameGeometry = [left, top, right, bottom],
        frameColor = color,
        strokeWidth = strokeWidth;

  FrameProperties.defineRatio(double ratio,
      {Color color = Colors.red, double? strokeWidth}) {
    this.frameColor = color;
    this.strokeWidth = strokeWidth;
    this.ratio = ratio;
  }
}

class FramePainter extends CustomPainter {
  final FrameProperties frameProperties;

  FramePainter(FrameProperties frameProperties)
      : frameProperties = frameProperties;

  @override
  void paint(Canvas canvas, Size size) {
    double left;
    double top;
    double right;
    double bottom;
    if (frameProperties.frameGeometry != null) {
      left = frameProperties.frameGeometry![0];
      top = frameProperties.frameGeometry![1];
      right = frameProperties.frameGeometry![2];
      bottom = frameProperties.frameGeometry![3];
    } else if (frameProperties.ratio != null) {
      // put the defined box in the center of the screen
      // at the maximum available size for the given ratio
      double ratio = frameProperties.ratio!;
      double w = size.width;
      double h = w / ratio;
      if (h > size.height) {
        h = size.height;
        w = h * ratio;
        left = (size.width - w) / 2;
        right = left;
        top = 0;
        bottom = 0;
      } else {
        top = (size.height - h) / 2;
        bottom = top;
        left = 0;
        right = 0;
      }
    } else {
      // put the defined box in the center of the screen
      left = (size.width - frameProperties.boxWidth!) / 2;
      top = (size.height - frameProperties.boxHeight!) / 2;
      right = left;
      bottom = top;
    }
    // draw using broders
    var style = frameProperties.strokeWidth != null
        ? PaintingStyle.stroke
        : PaintingStyle.fill;
    if (frameProperties.strokeWidth != null) {
      // draw just the frame
      Paint p = Paint()
        ..color = frameProperties.frameColor
        ..style = style
        ..strokeWidth = frameProperties.strokeWidth!;
      final rect = Rect.fromLTWH(
          left, top, size.width - left - right, size.height - top - bottom);
      canvas.drawRect(rect, p);
    } else {
      // draw colored area
      Paint p = Paint()
        ..color = frameProperties.frameColor
        ..style = style;
      canvas.drawRect(Rect.fromLTWH(0, 0, left, size.height), p);
      canvas.drawRect(
          Rect.fromLTWH(size.width - right, 0, size.width, size.height), p);
      canvas.drawRect(
          Rect.fromLTWH(left, 0, size.width - left - right, top), p);
      canvas.drawRect(
          Rect.fromLTWH(
              left, size.height - bottom, size.width - left - right, bottom),
          p);
      // p.blendMode = BlendMode.clear;
      // final transparentRect =
      //     Rect.fromLTWH(
      //     left, top, size.width - left - right, size.height - top - bottom);
      // canvas.drawRect(transparentRect, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
