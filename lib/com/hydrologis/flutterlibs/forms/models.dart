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

  void setFormUrlItem(String variableName, dynamic value) {
    setFormUrlItemSilently(variableName, value);
    notifyListenersMsg("Formhandler: set form url item");
  }

  void setFormUrlItemSilently(String variableName, dynamic value) {
    formUrlItems[variableName] = value.toString();
  }

  void removeFormUrlItem(String variableName) {
    removeFormUrlItemSilently(variableName);
    notifyListenersMsg("Formhandler: remove form url item");
  }

  void removeFormUrlItemSilently(String variableName) {
    formUrlItems.remove(variableName);
  }

  void resetFormUrlItems() {
    resetFormUrlItemsSilently();
    notifyListenersMsg("Formhandler: reset form url items");
  }

  void resetFormUrlItemsSilently() {
    formUrlItems = {};
  }

  String applyUrlSubstitutions(String url) {
    for (var entry in formUrlItems.entries) {
      var key = entry.key;
      var value = entry.value;

      url = url.replaceFirst("{$key}", value);
    }

    // replace any remaining placeholders with -1
    url = url.replaceAll(RegExp(r'{.*?}'), "-1");
    return url;
  }

  bool hasAllRequiredUrlItems(String url, Map<String, dynamic> formUrlItems) {
    // extract all {vars} from url
    var matches = RegExp(r'{(.*?)}').allMatches(url);
    // remove start and end { }
    var requiredVars = matches
        .map((e) => e.group(0)!.substring(1, e.group(0)!.length - 1))
        .toList();
    // check if one of the required vars is not in formUrlItems
    for (var requiredVar in requiredVars) {
      if (!formUrlItems.containsKey(requiredVar)) {
        return false;
      }
    }
    return true;
  }
}
