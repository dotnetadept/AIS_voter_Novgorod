import 'dart:io';
import 'dart:math';
import 'package:ais_model/ais_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:pdfrx/pdfrx.dart';
import '../Utils/utils.dart';
import '../Widgets/voting_utils.dart';
import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../State/AppState.dart';

class ViewDocumentPage extends StatefulWidget {
  ViewDocumentPage({Key? key}) : super(key: key);

  @override
  _ViewDocumentPageState createState() => _ViewDocumentPageState();
}

class _ViewDocumentPageState extends State<ViewDocumentPage> {
  QuestionFile? _currentDocument;
  String _documentPageCount = '0';
  String _errorMessage = '';
  String _documentPath = '';
  final controller = PdfViewerController();

  @override
  void initState() {
    super.initState();
    _currentDocument = AppState().getCurrentDocument();

    if (_currentDocument == null) {
      Provider.of<WebSocketConnection>(context, listen: false)
          .navigateToPage('viewAgenda');
    }

    _documentPath =
        '${GlobalConfiguration().getValue('folder_path')}/documents/' +
            _currentDocument!.relativePath +
            '/' +
            _currentDocument!.fileName;

    if (!File(_documentPath.replaceFirst('file:/', '')).existsSync()) {
      _errorMessage = 'Не найден документ: $_documentPath';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Expanded(
            child: AutoSizeText(
              _currentDocument?.description ?? '',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 300,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            icon: const Icon(Icons.zoom_in),
            onPressed: () => controller.zoomUp(),
          ),
          IconButton(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            icon: const Icon(Icons.zoom_out),
            onPressed: () => controller.zoomDown(),
          ),
          IconButton(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            icon: const Icon(Icons.first_page),
            onPressed: () => controller.goToPage(pageNumber: 1),
          ),
          IconButton(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            icon: const Icon(Icons.last_page),
            onPressed: () =>
                controller.goToPage(pageNumber: controller.pages.length),
          ),
        ],
      ),
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
          Expanded(
            child: PdfViewer.file(
              _documentPath,
              passwordProvider: () => null,
              controller: controller,
              params: PdfViewerParams(
                maxScale: 8,
                errorBannerBuilder: (context, error, stackTrace, documentRef) =>
                    Container(
                  child:
                      Text('Невозможно открыть файл:\r\n${error.toString()}'),
                ),
                layoutPages: (pages, params) {
                  final height = pages.fold(0.0, (prev, page) => page.height) +
                      params.margin * 2;
                  final pageLayouts = <Rect>[];
                  double x = params.margin;
                  for (final page in pages) {
                    pageLayouts.add(
                      Rect.fromLTWH(
                        x,
                        (height - page.height) / 2, // center vertically
                        page.width,
                        page.height,
                      ),
                    );
                    x += page.width + params.margin;
                  }
                  return PdfPageLayout(
                      pageLayouts: pageLayouts, documentSize: Size(x, height));
                },
                viewerOverlayBuilder: (context, size, handleLinkTap) => [
                  //
                  // Scroll-thumbs example
                  //
                  // Show vertical scroll thumb on the right; it has page number on it
                  PdfViewerScrollThumb(
                    controller: controller,
                    orientation: ScrollbarOrientation.right,
                    thumbSize: const Size(40, 25),
                    thumbBuilder:
                        (context, thumbSize, pageNumber, controller) =>
                            Container(
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          pageNumber.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  // Just a simple horizontal scroll thumb on the bottom
                  PdfViewerScrollThumb(
                    controller: controller,
                    orientation: ScrollbarOrientation.bottom,
                    thumbSize: const Size(80, 30),
                    thumbBuilder:
                        (context, thumbSize, pageNumber, controller) =>
                            Container(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          getButtonsSection(),
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
                        fixedSize: WidgetStateProperty.all(Size(190, 50)),
                        padding: WidgetStateProperty.all(EdgeInsets.all(0))),
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
