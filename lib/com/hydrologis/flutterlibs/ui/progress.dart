part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

class SmashCircularProgress extends StatelessWidget {
  final String? label;
  final bool doTitle;
  final bool doBold;

  SmashCircularProgress(
      {this.label, Key? key, this.doTitle = false, this.doBold = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      Widget textWidget;
      if (doTitle) {
        textWidget = SmashUI.titleText(label!, bold: doBold);
      } else {
        textWidget = SmashUI.normalText(label!, bold: doBold);
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(
              height: 10,
            ),
            textWidget,
          ],
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
