import 'package:flutter/material.dart';

class Utility {
  Future<void> showMessageOkDialog(BuildContext context,
      {String title, TextSpan message, String okButtonText}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      children: <TextSpan>[
                        message,
                      ]),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              child: TextButton(
                child: Text(okButtonText),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showYesNoDialog(
    BuildContext context, {
    String title,
    TextSpan message,
    String yesButtonText,
    String noButtonText,
    VoidCallback yesCallBack,
    VoidCallback noCallBack,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      children: <TextSpan>[
                        message,
                      ]),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              child: TextButton(
                child: Text(yesButtonText),
                onPressed: () {
                  yesCallBack();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: TextButton(
                child: Text(noButtonText),
                onPressed: () {
                  noCallBack();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showYesNoOptionsDialog(
    BuildContext context, {
    String title,
    String text,
    List<String> options,
    String yesButtonText,
    String noButtonText,
    void Function(String) yesCallBack,
    VoidCallback noCallBack,
  }) async {
    String selectedOption = options.first;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateForDialog) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: ListBody(
                  children: options.map((e) {
                    return Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                      child: RadioListTile<bool>(
                        title: Text(e),
                        value: true,
                        groupValue: e == selectedOption,
                        onChanged: (bool value) {
                          selectedOption = e;
                          setStateForDialog(() {});
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  child: TextButton(
                    child: Text(yesButtonText),
                    onPressed: () {
                      yesCallBack(selectedOption);
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: TextButton(
                    child: Text(noButtonText),
                    onPressed: () {
                      noCallBack();
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
