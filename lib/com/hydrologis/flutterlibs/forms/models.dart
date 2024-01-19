part of smashlibs;

class FormHandlerState extends ChangeNotifierPlus {

  String? selectedTabName;

  void setSelectedTabName(String name) {
    selectedTabName = name;
    notifyListenersMsg("Formhandler: selected tab changed");
  }


  void onChanged() {
    notifyListenersMsg("forms changed");
  }
}
