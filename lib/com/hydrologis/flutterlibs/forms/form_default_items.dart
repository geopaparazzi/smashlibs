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
    "simple date": """
    {
      "key": "date_key",
      "value": "",
      "type": "$TYPE_DATE"
    }""",
    "date with default set": """
    {
      "key": "date_with_default_key",
      "value": "2023-06-29",
      "type": "$TYPE_DATE"
    }"""
  },
  TYPE_TIME: {
    "simple time": """
    {
      "key": "time_key",
      "value": "simple",
      "type": "$TYPE_TIME"
    }""",
    "time with default set": """
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
                  "value": "-1"
              }
          }
        ],
        "url": "https://raw.githubusercontent.com/geopaparazzi/smashlibs/feature-fb/example/smashlibs_mapexample/assets/combo_string_items_example.json"
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
        "url": "https://raw.githubusercontent.com/geopaparazzi/smashlibs/feature-fb/example/smashlibs_mapexample/assets/combo_int_items_example.json"
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
  TYPE_PICTURES: {
    "a camera picture": """
    {
      "key": "pictures_key",
      "value": "",
      "type": "$TYPE_PICTURES"
    }""",
    "a picture from the gallery": """
    {
      "key": "pictures_from_lib_key",
      "value": "",
      "type": "$TYPE_IMAGELIB"
    }"""
  },
  TYPE_SKETCH: {
    "a sketch": """
    {
      "key": "sketch_key",
      "value": "",
      "type": "$TYPE_SKETCH"
    }"""
  },
  TYPE_POINT: {
    "an existing point with style": """
    {
      "key": "a point geometry",
      "value": {
        "type": "Point",
        "coordinates": [11.66, 46.5]
      },
      "style": {
        "icon": "tree",
        "color": "#FF0000",
        "size": 15
      },
      "type": "$TYPE_POINT"
    }""",
    "an empty point with style": """
    {
      "key": "a point geometry",
      "value": "",
      "style": {
        "icon": "tree",
        "color": "#FF0000",
        "size": 15
      },
      "type": "$TYPE_POINT"
    }"""
  },
  TYPE_LINESTRING: {
    "an existing linestring with style": """
    {
      "key": "a line geometry",
      "value": {
        "type": "LineString",
        "coordinates": [
          [11.66, 46.5],
          [11.76, 46.6],
          [11.56, 46.7]
        ]
      },
      "style": {
        "color": "#0000FF",
        "width": 4
      },
      "type": "$TYPE_LINESTRING"
    }""",
  },
  TYPE_POLYGON: {
    "an existing polygon with style": """
    {
      "key": "a polygon geometry",
      "value": {
        "type": "Polygon",
        "coordinates": [
          [
            [11.66, 46.5],
            [11.76, 46.6],
            [11.56, 46.7],
            [11.66, 46.5]
          ]
        ]
      },
      "style": {
        "color": "#FF0000",
        "width": 2,
        "opacity": 0.2
      },
      "type": "$TYPE_POLYGON"
    }""",
  },
};
