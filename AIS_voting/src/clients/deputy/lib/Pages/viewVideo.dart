import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:deputy/State/AppState.dart';
import 'package:deputy/State/WebSocketConnection.dart';
import 'package:deputy/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';
import '../State/VideoSignal.dart';
import '../Widgets/voting_utils.dart';
import 'package:statsfl/statsfl.dart';

class ViewVideoPage extends StatefulWidget {
  ViewVideoPage({Key key}) : super(key: key);

  @override
  _ViewVideoPageState createState() => _ViewVideoPageState();
}

class _ViewVideoPageState extends State<ViewVideoPage> {
  Signaling _signaling;
  RTCVideoRenderer _renderer;

  bool _isPlayerStarted = false;
  bool _isPlayerRefreshStarted = true;
  bool _isPlayerRefreshPressed = false;
  bool _isPlayerDisconnected = false;
  bool _isShowFPS = GlobalConfiguration().getValue('player_show_fps') == 'true';
  bool _isShowReload =
      GlobalConfiguration().getValue('player_show_reload') == 'true';

  @override
  void initState() {
    super.initState();

    _startStream();

    AppState.refreshStream = _refreshStream;
  }

  Future<void> _startStream() async {
    _renderer = RTCVideoRenderer();
    await _renderer.initialize();

    await connectVideoPlayer();
  }

  Future<void> _closeStream() async {
    if (_isShowReload == true) {
      _isPlayerStarted = false;
      setState(() {});
    }

    if (_renderer?.srcObject != null) {
      await _renderer?.dispose();
      _renderer = null;
    }

    _signaling?.onStreamCancel = null;
    _signaling?.onAddRemoteStream = null;
    await _signaling?.close();
    _signaling = null;
  }

  Future<void> _refreshStream() async {
    if (_isPlayerRefreshStarted == true) {
      return;
    }
    _isPlayerRefreshStarted = true;

    if (AppState().getCurrentPage() != '/viewVideo') {
      return;
    }

    await _closeStream().then((value) async {
      Timer(Duration(seconds: 2), _startStream);
    });
  }

  Future<void> connectVideoPlayer() async {
    if (_signaling == null) {
      _signaling = Signaling();
      _signaling.connect();
    }

    _signaling?.onStreamCancel = () {
      if (_isShowReload == true) {
        _isPlayerStarted = false;
      }

      _isPlayerDisconnected = true;
      _isPlayerRefreshStarted = false;
      _isPlayerRefreshPressed = false;
      setState(() {});
    };

    _signaling?.onAddRemoteStream = ((_, stream) async {
      _renderer.srcObject = stream;
      _isPlayerDisconnected = false;
      setState(() {});

      _renderer.onFirstFrameRendered = () {
        _isPlayerStarted = true;
        _isPlayerRefreshStarted = false;
        _isPlayerRefreshPressed = false;
        setState(() {});
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      backgroundColor: Colors.blue[100],
    );
  }

  Widget body() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 200,
            child: _isPlayerStarted
                ? _isShowFPS
                    ? StatsFl(
                        isEnabled: true,
                        maxFps: 90,
                        width: 200,
                        height: 30,
                        align: Alignment.topLeft,
                        child: RTCVideoView(
                          _renderer,
                        ),
                      )
                    : RTCVideoView(
                        _renderer,
                      )
                : Container(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Загрузка',
                            style: TextStyle(fontSize: 32),
                          ),
                          Container(
                            width: 15,
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: bottomPanel(),
            ),
          ],
        ),
      ],
    );
  }

  Widget bottomPanel() {
    final connection = Provider.of<WebSocketConnection>(context, listen: true);

    return Container(
      padding: EdgeInsets.all(0),
      color: Colors.grey,
      child: Row(
        children: [
          Expanded(
            child: getButtonsSection(),
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
              Container(
                width: 20,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                child: GestureDetector(
                  onTapDown: _isPlayerRefreshStarted || _isPlayerRefreshPressed
                      ? null
                      : (TapDownDetails d) async {
                          _setState(() {
                            _isPlayerRefreshPressed = true;
                          });
                          await _refreshStream();
                        },
                  child: TextButton(
                    onPressed:
                        _isPlayerRefreshStarted || _isPlayerRefreshPressed
                            ? null
                            : () async {
                                _setState(() {
                                  _isPlayerRefreshPressed = true;
                                });
                                await _refreshStream();
                              },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(150, 50)),
                      padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                      backgroundColor: MaterialStateProperty.all(
                          _isPlayerRefreshStarted
                              ? Colors.grey
                              : Colors.blueAccent),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                        ),
                        Icon(
                          Icons.refresh,
                          color:
                              _isPlayerDisconnected ? Colors.red : Colors.white,
                        ),
                        Container(
                          width: 10,
                        ),
                        Text(
                          'Обновить',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
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
              AppState().getServerState().streamControl == 'user'
                  ? Padding(
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
                              fixedSize:
                                  MaterialStateProperty.all(Size(190, 50)),
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(0))),
                          child: Text(
                            'Назад к повестке',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    )
                  : Container(),
              Expanded(child: Container()),
            ],
          ),
          Row(
            children: [
              Expanded(child: Container()),
              Utils().getIsAskWordButtonDisabled()
                  ? Container()
                  : VotingUtils().getAskWordButton(
                      _context,
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
    AppState().setExitStream(true);
    connection.navigateToPage('/viewAgenda');
  }

  @override
  void deactivate() async {
    super.deactivate();

    if (_renderer?.srcObject != null) {
      _renderer?.srcObject = null;
      await _renderer?.dispose();
      _renderer = null;
    }

    _signaling?.onAddRemoteStream = null;
    _signaling?.onStreamCancel = null;
    await _signaling?.close();
    _signaling = null;

    AppState.refreshStream = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
