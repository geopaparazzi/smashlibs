part of smashlibs;

/// Helper class in cases of advanced camera use.
/// Make sue yourt app initialises the init of thsi as follows at app startup:
///
// class HomeWidgetState extends State<WelcomeWidget>
//   with WidgetsBindingObserver {
//    CameraState? cameraState;
//
//    @override
//    void initState() {
//      cameraState = Provider.of<CameraState>(context, listen: false);
//
//      super.initState();
//      WidgetsBinding.instance.addObserver(this);
//
//      ...
//    }
//
//    @override
//    void didChangeDependencies() {
//      super.didChangeDependencies();
//      if (cameraState != null) {
//        cameraState!.init(context);
//      }
//    }
//
//    @override
//    void dispose() {
//      WidgetsBinding.instance.removeObserver(this);
//      super.dispose();
//    }
// ...
//
class CameraState extends ChangeNotifierPlus {
  DeviceOrientation? startupOrientation;

  void init(BuildContext context) {
    if (startupOrientation != null) {
      return;
    }
    startupOrientation = getOrientation(context);
  }

  void onChanged() {
    notifyListenersMsg("camera state changed");
  }

  DeviceOrientation getOrientation(BuildContext context,
      {bool setPreferred = false}) {
    DeviceOrientation initialOrientation;
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait) {
      if (setPreferred) {
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      }
      var view = View.of(context);
      view.viewInsets.bottom == 0
          ? initialOrientation = DeviceOrientation.portraitUp
          : initialOrientation = DeviceOrientation.portraitDown;
    } else {
      if (setPreferred) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
      }

      initialOrientation =
          MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
              ? DeviceOrientation.landscapeLeft
              : DeviceOrientation.landscapeRight;
    }
    return initialOrientation;
  }
}
