import 'dart:io';
import 'package:ais_model/ais_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:global_configuration/global_configuration.dart';
import '../Utils/utils.dart';
import '../Widgets/voting_utils.dart';
import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../State/AppState.dart';

class ViewDocumentPage extends StatefulWidget {
  ViewDocumentPage({Key key}) : super(key: key);

  @override
  _ViewDocumentPageState createState() => _ViewDocumentPageState();
}

class _ViewDocumentPageState extends State<ViewDocumentPage> {
  QuestionFile _currentDocument;
  String _documentPageCount = '0';
  @override
  void initState() {
    super.initState();
    _currentDocument = AppState().getCurrentDocument();

    if (_currentDocument == null) {
      Provider.of<WebSocketConnection>(context, listen: false)
          .navigateToPage('viewAgenda');
    }

    String documentPath =
        'file:/${GlobalConfiguration().getValue('folder_path')}/documents/' +
            _currentDocument.relativePath +
            '/' +
            _currentDocument.fileName;

    openDocument(documentPath);
  }

  void openDocument(String documentPath) {
    // load new evince window on top of main
    try {
      var stats = Process.runSync('pdfinfo', <String>[documentPath]);
      var statsLines = stats.stdout.toString().split('\n').toList();
      for (var i = 0; i < statsLines.length; i++) {
        if (statsLines[i] != null &&
            statsLines[i].isNotEmpty &&
            statsLines[i].toLowerCase().trim().startsWith('pages:')) {
          setState(() {
            _documentPageCount =
                statsLines[i].toLowerCase().replaceAll('pages:', '').trim();
          });
          break;
        }
      }
      print('Путь документа:$documentPath\n');
      Process.run('evince', <String>[documentPath]);
    } catch (exc) {
      print('Ошибка evice: $exc\n');
    }
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
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Text(
                  _currentDocument.description,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: Text('($_documentPageCount стр.) '),
            ),
          ]),
          Expanded(
            child: Container(),
          ),
          Row(children: [
            Expanded(
              child: Container(),
            ),
            Container(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ),
            Container(
              width: 15,
            ),
            Text(
              'Загрузка ...',
              style: TextStyle(fontSize: 20),
            ),
            Expanded(
              child: Container(),
            ),
          ]),
          Expanded(
            child: Container(),
          ),
          getButtonsSection(),
          Container(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget getButtonsSection() {
    return StatefulBuilder(builder: (_context, _setState) {
      final connection =
          Provider.of<WebSocketConnection>(_context, listen: true);
      return Container(
        color: Colors.black12,
        child: Stack(children: <Widget>[
          Row(
            children: [
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: GestureDetector(
                  onTapDown: (TapDownDetails d) {
                    backToAgenda(connection);
                  },
                  child: TextButton(
                    onPressed: () {
                      backToAgenda(connection);
                    },
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(Size(190, 50)),
                        padding: MaterialStateProperty.all(EdgeInsets.all(0))),
                    child: Text(
                      'Назад к повестке',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
          Row(
            children: [
              Expanded(child: Container()),
              Utils().getIsAskWordButtonDisabled()
                  ? Container()
                  : VotingUtils().getAskWordButton(
                      context,
                      setState,
                      AutoSizeGroup(),
                      50,
                      300,
                      true,
                    ),
              Container(
                width: 20,
              ),
            ],
          ),
        ]),
      );
    });
  }

  void backToAgenda(WebSocketConnection connection) {
    if (AppState().canUserNavigate()) {
      AppState().setCurrentDocument(null);

      connection.navigateToPage('/viewAgenda');
    }
  }

  void onAskWord(WebSocketConnection connection) {
    if (AppState().getAskWordStatus()) {
      connection.sendMessage('ПРОШУ СЛОВА СБРОС');
    } else {
      connection.sendMessage('ПРОШУ СЛОВА');
    }
  }
}
