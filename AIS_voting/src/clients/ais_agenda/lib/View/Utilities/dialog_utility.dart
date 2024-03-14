import 'package:flutter/material.dart';

class DialogUtility {
  Future<void> showMessageOkDialog(BuildContext context,
      {required String title,
      required TextSpan message,
      required String okButtonText}) async {
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
                      style: const TextStyle(
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
              margin: const EdgeInsets.all(10),
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
                      style: const TextStyle(
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
              margin: const EdgeInsets.all(10),
              child: TextButton(
                child: Text(yesButtonText),
                onPressed: () {
                  yesCallBack();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
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
}
