part of smashlibs;

const Map<String, Map<String, String>> DEFAULT_FORM_ITEMS = {
  TYPE_STRING: {
    "string": """
    {
      "key": "string_key",
      "label": "string label",
      "value": "default value",
      "icon": "font",
      "type": "$TYPE_STRING"
    }""",
    "string as map label": """
    {
      "key": "string_key",
      "label": "string label",
      "islabel": "true",
      "value": "default value",
      "icon": "font",
      "type": "$TYPE_STRING"
    }""",
  },
  TYPE_STRINGAREA: {
    "text area": """
    {
      "key": "text_area_key",
      "label": "text area label",
      "value": "default value 1\ndefault value 2",
      "icon": "scroll",
      "type": "$TYPE_STRINGAREA"
    }"""
  },
  TYPE_DOUBLE: {
    TYPE_DOUBLE: """
    {
      "key": "double_key",
      "label": "double label",
      "value": "123.45",
      "type": "$TYPE_DOUBLE"
    }"""
  },
  TYPE_INTEGER: {
    TYPE_INTEGER: """
    {
      "key": "integer_key",
      "label": "integer label",
      "value": "12345",
      "type": "$TYPE_INTEGER"
    }"""
  },
  TYPE_LABELWITHLINE: {
    "label with line": """
          {
      "key": "labelwithline_key",
      "value": "default underlined label value",
      "size": "24",
      "type": "$TYPE_LABELWITHLINE"
    }""",
    "label with tappable url": """
    {
      "value": "a label with link to the geopaparazzi homepage",
      "url": "http://www.geopaparazzi.eu",
      "size": "20",
      "type": "labelwithline"
    }"""
  },
  TYPE_LABEL: {
    TYPE_LABEL: """
    {
      "key": "label_key",
      "value": "default label value",
      "size": "20",
      "type": "$TYPE_LABEL"
    }"""
  },
  TYPE_DYNAMICSTRING: {
    TYPE_DYNAMICSTRING: """
    {
      "key": "dynamicstring_key",
      "value": "text1; text2; text3",
      "type": "$TYPE_DYNAMICSTRING"
    }"""
  },
  TYPE_DATE: {
    TYPE_DATE: """
    {
      "key": "date_key",
      "value": "2023-06-29",
      "type": "$TYPE_DATE"
    }"""
  },
  TYPE_TIME: {
    TYPE_TIME: """
    {
      "key": "time_key",
      "value": "08:38:00",
      "type": "$TYPE_TIME"
    }"""
  },
  TYPE_BOOLEAN: {
    TYPE_BOOLEAN: """
    {
      "key": "boolean_key",
      "value": "",
      "icon": "questionCircle",
      "type": "$TYPE_BOOLEAN"
    }"""
  },
  TYPE_STRINGCOMBO: {
    "string combo": """
    {
      "key": "string_combo_key",
      "values": {
        "items": [
          {
            "item": "choice 1"
          },
          {
            "item": "default choice 2"
          },
          {
            "item": "choice 3"
          }
        ]
      },
      "value": "default choice 2",
      "type": "$TYPE_STRINGCOMBO"
    }""",
    "string combo with item labels": """
    {
      "key": "string_combo_with_labels_key",
      "values": {
        "items": [
          {
            "item": {
              "label": "",
              "value": "0"
            }
          },
          {
            "item": {
              "label": "choice 1",
              "value": "1"
            }
          },
          {
            "item": {
              "label": "choice 2",
              "value": "2"
            }
          }
        ]
      },
      "value": "1",
      "type": "$TYPE_STRINGCOMBO"
    }""",
    "string combo with data from url": """
    {
      "key": "string_combo_urlbased_key",
      "values": {
        "items": [
          {
              "item": {
                  "label": "No data",
                  "value": -1
              }
          }
        ],
        "url": "https://www.mydataproviderurl.com/api/v1/data.json"
      },
      "value": "",
      "type": "$TYPE_STRINGCOMBO"
    }"""
  },
  TYPE_INTCOMBO: {
    "int combo": """
     {
      "key": "int_single_choice_combo_key",
      "values": {
        "items": [
          {
            "item": 0
          },
          {
            "item": 1
          },
          {
            "item": 2
          }
        ]
      },
      "value": 1,
      "type": "$TYPE_INTCOMBO"
    }""",
    "int combo with item labels": """          
    {
      "key": "int_single_choice_combo_with_labels_key",
      "values": {
        "items": [
          {
            "item": {
              "label": "",
              "value": 0
            }
          },
          {
            "item": {
              "label": "choice 1",
              "value": 1
            }
          },
          {
            "item": {
              "label": "choice 2",
              "value": 2
            }
          }
        ]
      },
      "value": 1,
      "type": "$TYPE_INTCOMBO"
    }""",
    "int combo with data from url": """
    {
      "key": "int_single_choice_combo_urlbased_key",
      "values": {
        "url": "https://www.mydataproviderurl.com/api/v1/data.json"
      },
      "value": 0,
      "type": "intcombo"
    }"""
  },
  TYPE_CONNECTEDSTRINGCOMBO: {
    "$TYPE_CONNECTEDSTRINGCOMBO": """
    {
      "key": "two_connected_combos_key",
      "values": {
        "items 1": [
          {
            "item": ""
          },
          {
            "item": "choice 1 of 1"
          },
          {
            "item": "choice 2 of 1"
          }
        ],
        "items 2": [
          {
            "item": ""
          },
          {
            "item": "choice 1 of 2"
          },
          {
            "item": "choice 2 of 2"
          }
        ]
      },
      "value": "items 2#choice 1 of 2",
      "type": "$TYPE_CONNECTEDSTRINGCOMBO"
    }"""
  },
  TYPE_AUTOCOMPLETESTRINGCOMBO: {
    TYPE_AUTOCOMPLETESTRINGCOMBO: """
    {
      "key": "autocomplete_string_combo_key",
      "values": {
        "items": [
          {
            "item": ""
          },
          {
            "item": "choice 1"
          },
          {
            "item": "choice 2"
          },
          {
            "item": "choice 3"
          },
          {
            "item": "choice 4"
          },
          {
            "item": "choice 5"
          }
        ]
      },
      "value": "",
      "type": "$TYPE_AUTOCOMPLETESTRINGCOMBO"
    }"""
  },
  TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO: {
    TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO: """
    {
      "key": "two_connected_autocomplete_combos_key",
      "values": {
        "items 1": [
          {
            "item": ""
          },
          {
            "item": "choice 1 of 1"
          },
          {
            "item": "choice 2 of 1"
          }
        ],
        "items 2": [
          {
            "item": ""
          },
          {
            "item": "choice 1 of 2"
          },
          {
            "item": "choice 2 of 2"
          }
        ]
      },
      "value": "",
      "type": "$TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO"
    }"""
  },
  TYPE_STRINGMULTIPLECHOICE: {
    "multiple choice string combo": """
    {
      "formname": "combos",
      "formitems": [
        {
          "key": "multiple_choice_combo_key",
          "values": {
            "items": [
              {
                "item": ""
              },
              {
                "item": "choice 1"
              },
              {
                "item": "choice 2"
              }
            ]
          },
          "value": "",
          "type": "multistringcombo"
        }
      ]
    }""",
    "multiple choice string combo with item labels": """
    {
      "key": "multiple_choice_combo_with_labels_key",
      "values": {
        "items": [
          {
            "item": {
              "label": "",
              "value": "0"
            }
          },
          {
            "item": {
              "label": "choice 1",
              "value": "1"
            }
          },
          {
            "item": {
              "label": "choice 2",
              "value": "2"
            }
          }
        ]
      },
      "value": "",
      "type": "$TYPE_STRINGMULTIPLECHOICE"
    }""",
    "multiple choice string combo with data from url": """
    {
      "key": "multi_choice_string_combo_urlbased_key",
      "values": {
        "url": "https://www.mydataproviderurl.com/api/v1//data.json"
      },
      "value": "",
      "type": "$TYPE_STRINGMULTIPLECHOICE"
    }"""
  },
  TYPE_INTMULTIPLECHOICE: {
    "multiple choice int combo": """
    {
      "key": "int_multiple_choice_combo_key",
      "values": {
        "items": [
          {
            "item": 0
          },
          {
            "item": 1
          },
          {
            "item": 2
          }
        ]
      },
      "value": "",
      "type": "$TYPE_INTMULTIPLECHOICE"
    }""",
    "multiple choice int combo with item labels": """
    {
      "key": "int_multiple_choice_combo_with_labels_key",
      "values": {
        "items": [
          {
            "item": {
              "label": "",
              "value": 0
            }
          },
          {
            "item": {
              "label": "choice 1",
              "value": 1
            }
          },
          {
            "item": {
              "label": "choice 2",
              "value": 2
            }
          }
        ]
      },
      "value": "",
      "type": "$TYPE_INTMULTIPLECHOICE"
    }""",
  },
  //      MultiIntComboItem(
  //         context, widgetKey, formItem, presentationMode, formHelper);
  //   TYPE_PICTURES:
  //      PicturesItem(
  //         context, widgetKey, formItem, presentationMode, formHelper);
  //   TYPE_IMAGELIB:
  //      PicturesItem(
  //         context, widgetKey, formItem, presentationMode, formHelper,
  //         fromGallery: true);
  //   TYPE_SKETCH:
  //      SketchItem(
  //         context, widgetKey, formItem, presentationMode, formHelper);
  //   TYPE_POINT:
  //      PointItem(
  //         context, widgetKey, formItem, presentationMode, formHelper);
  //   TYPE_MULTIPOINT:
  //      MultiPointItem(
  //         context, widgetKey, formItem, presentationMode, formHelper);
  //   TYPE_LINESTRING:
  //      LineStringItem(
  //         context, widgetKey, formItem, presentationMode, formHelper);
  //   TYPE_MULTILINESTRING:
  //      MultiLineStringItem(
  //         context, widgetKey, formItem, presentationMode, formHelper);
  //   TYPE_POLYGON:
  //      PolygonItem(
  //         context, widgetKey, formItem, presentationMode, formHelper);
  //   TYPE_MULTIPOLYGON:
  //      MultiPolygonItem(
  //         context, widgetKey, formItem, presentationMode, formHelper);
  //   TYPE_HIDDEN:
  //      null; // TODO Container();
  //   default:
  //     print("Type non implemented yet: $typeName");
  //      null; // TODO Container();
  // }
  //  "";
};
