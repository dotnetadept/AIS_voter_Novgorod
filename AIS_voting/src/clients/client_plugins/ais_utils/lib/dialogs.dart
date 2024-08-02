import 'package:flutter/material.dart';

class Utility {
  Future<void> showMessageOkDialog(
    BuildContext context, {
    required String title,
    required TextSpan message,
    required String okButtonText,
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
    required String title,
    required TextSpan message,
    required String yesButtonText,
    required String noButtonText,
    required VoidCallback yesCallBack,
    required VoidCallback noCallBack,
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
    required String title,
    required String text,
    required List<String> options,
    required String yesButtonText,
    required String noButtonText,
    required void Function(String) yesCallBack,
    required VoidCallback noCallBack,
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
                        onChanged: (bool? value) {
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
