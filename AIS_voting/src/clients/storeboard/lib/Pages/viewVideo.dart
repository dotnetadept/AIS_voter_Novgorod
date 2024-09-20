import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:global_configuration/global_configuration.dart';
import '../State/AppState.dart';
import '../State/VideoSignal.dart';
import 'package:statsfl/statsfl.dart';

class ViewVideoPage extends StatefulWidget {
  ViewVideoPage({Key? key}) : super(key: key);

  @override
  _ViewVideoPageState createState() => _ViewVideoPageState();
}

class _ViewVideoPageState extends State<ViewVideoPage> {
  Signaling? _signaling;
  RTCVideoRenderer? _renderer;

  bool _isPlayerStarted = false;
  bool _isShowFPS = GlobalConfiguration().getValue('player_show_fps') == 'true';
  bool _isShowReload =
      GlobalConfiguration().getValue('player_show_reload') == 'true';

  @override
  void initState() {
    super.initState();

    _startStream();
  }

  Future<void> _startStream() async {
    if (_renderer == null) {
      _renderer = RTCVideoRenderer();
      await _renderer!.initialize();
    }

    await connectVideoPlayer();

    AppState.refreshStream = _refreshStream;
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
    AppState.refreshStream = null;

    if (AppState().getCurrentPage() != '/viewVideo') {
      return;
    }

    await _closeStream().then((value) async {
      Timer(Duration(seconds: 1), _startStream);
    });
  }

  Future<void> connectVideoPlayer() async {
    if (_signaling == null) {
      _signaling = Signaling();
      _signaling!.connect();
    }

    _signaling?.onStreamCancel = () {
      if (_isShowReload == true) {
        _isPlayerStarted = false;
      }

      setState(() {});
    };

    _signaling?.onAddRemoteStream = ((_, stream) async {
      _renderer?.srcObject = stream;

      _renderer?.onFirstFrameRendered = () {
        _isPlayerStarted = true;

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
            height: MediaQuery.of(context).size.height,
            child: _isPlayerStarted
                ? _isShowFPS
                    ? StatsFl(
                        isEnabled: true,
                        maxFps: 90,
                        width: 200,
                        height: 30,
                        align: Alignment.topLeft,
                        child: RTCVideoView(
                          _renderer!,
                        ),
                      )
                    : RTCVideoView(
                        _renderer!,
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
      ],
    );
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
