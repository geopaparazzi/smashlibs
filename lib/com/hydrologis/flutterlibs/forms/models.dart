part of smashlibs;

class FormHandlerState extends ChangeNotifierPlus {
  String? selectedTabName;
  Map<String, String> formUrlItems = {};

  void setSelectedTabName(String name) {
    selectedTabName = name;
    notifyListenersMsg("Formhandler: selected tab changed");
  }

  void onChanged() {
    notifyListenersMsg("forms changed");
  }
}

class FormUrlItemsState extends ChangeNotifierPlus {
  Map<String, String> formUrlItems = {};

  void setFormUrlItem(String variableName, String value) {
    setFormUrlItemSilently(variableName, value);
    notifyListenersMsg("Formhandler: set form url item");
  }

  void setFormUrlItemSilently(String variableName, String value) {
    formUrlItems[variableName] = value;
  }

  void resetFormUrlItems() {
    formUrlItems = {};
    notifyListenersMsg("Formhandler: reset form url items");
  }
}
