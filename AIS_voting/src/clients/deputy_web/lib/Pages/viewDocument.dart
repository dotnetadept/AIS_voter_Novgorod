import 'dart:html';
import 'dart:ui' as ui;

import 'package:deputy/State/AppState.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class ViewDocumentPage extends StatefulWidget {
  ViewDocumentPage({Key key}) : super(key: key);

  @override
  _ViewDocumentPageState createState() => _ViewDocumentPageState();
}

class _ViewDocumentPageState extends State<ViewDocumentPage> {
  List<String> _links = <String>[
    'http://87.255.252.235/Products/Files/DocEditor.aspx?fileid=5&action=view&doc=em9iR3hRMjAvMng2b09Sc1lOcHBHZkxKc2FGNEtyZUNoU1FBVVN5MHRTQT0_IjUi0',
    'http://87.255.252.235/Products/Files/DocEditor.aspx?fileid=11&action=view&doc=eVRMS3E4dnY1WkpaZTlkTU9iOGJhZEFQcXh3emgxNkJFZ2VCdmw3U3FScz0_IjExIg2',
    'http://87.255.252.235/Products/Files/DocEditor.aspx?fileid=13&action=view&doc=VUtERzZwdUhzOTh3bnI3am91SlRtYXNOOVZRa3ltR1JkaHp1R051RWJQZz0_IjEzIg2',
    'http://87.255.252.235/Products/Files/DocEditor.aspx?fileid=12&action=view&doc=aWVISG9wbGR0S0d2bSthWWlVaGJtbTRaaFF1c2hnUUU2cjNsTDZnTUJJUT0_IjEyIg2'
  ];

  Widget _currentIframe;
  List<Widget> _iframes = <Widget>[];
  List<IFrameElement> _iframeElements = <IFrameElement>[];

  @override
  void initState() {
    for (int i = 0; i < 4; i++) {
      _iframes.add(HtmlElementView(
        key: UniqueKey(),
        viewType: 'iframeElement' + i.toString(),
      ));
      var iframe = IFrameElement();

      iframe.height = '500';
      iframe.width = '500';
      iframe.src = _links[i];
      iframe.inputMode = 'none';
      iframe.style.border = 'none';

      _iframeElements.add(iframe);

      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        'iframeElement' + i.toString(),
        (int viewId) => iframe,
      );
    }
    var fileIndex = AppState()
            .getSelectedQuestion()
            .files
            .indexOf(AppState().getSelectedQuestionFile()) %
        4;

    _currentIframe = _iframes[fileIndex];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      backgroundColor: Colors.blue[100],
    );
  }

  Widget body() {
    return Row(
      children: <Widget>[
        Expanded(
          child: viewDocumentPanel(),
        ),
      ],
    );
  }

  Widget viewDocumentPanel() {
    return Container(
      padding: EdgeInsets.all(0),
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Container(),
          ),
          SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              width: MediaQuery.of(context).size.width,
              child: _currentIframe),
          Expanded(
            child: Container(),
          ),
          getButtonsSection(),
        ],
      ),
    );
  }

  Widget getButtonsSection() {
    return StatefulBuilder(builder: (_context, _setState) {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
        child: Row(
          children: [
            Expanded(child: Container()),
            TextButton(
              onPressed: () async {
                AppState().setSelectedQuestion(null);
                await Navigator.of(context).pushNamedAndRemoveUntil(
                    '/viewAgenda', (Route<dynamic> route) => false);
              },
              style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(Size(220, 50))),
              child: Text('Назад к повестке'),
            ),
            Container(width: 20),
            ButtonTheme(
              height: 50,
              minWidth: 220,
              child: TextButton(
                onPressed: () async {
                  await Navigator.of(context).pushNamedAndRemoveUntil(
                      '/viewAgenda', (Route<dynamic> route) => false);
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(220, 50),
                  ),
                ),
                child: Text('Назад к вопросу'),
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
      );
    });
  }
}
