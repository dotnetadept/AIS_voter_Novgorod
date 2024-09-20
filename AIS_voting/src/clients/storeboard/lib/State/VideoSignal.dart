import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:storeboard/State/AppState.dart';
import 'package:web_socket_channel/io.dart';

import '../Utils/random_string.dart';

class Session {
  Session({required this.sid, required this.pid});
  String pid;
  String sid;
  late RTCPeerConnection pc;
  late RTCDataChannel dc;
}

class Signaling {
  String _host = GlobalConfiguration().getValue('oven_media_server');
  int _port = int.parse(GlobalConfiguration().getValue('oven_signaling_port'));

  String _selfId = randomNumeric(6);

  WebSocket? _socket;
  IOWebSocketChannel? _channel;

  Session? _session;

  JsonEncoder _encoder = JsonEncoder();
  JsonDecoder _decoder = JsonDecoder();

  bool _wasClosed = false;

  Function(Session session, MediaStream stream)? onAddRemoteStream;
  Function()? onStreamCancel;

  Signaling();

  Future<void> connect() async {
    var url = 'ws://$_host:$_port/app/stream?transport=tcp';
    await WebSocket.connect(url).then((value) {
      print('Websocket of OvenMediaPlayer connected to: $url');

      _channel = IOWebSocketChannel(value);
      _socket = value;

      _channel!.stream.listen((data) {
        if (data == '{"code":404,"error":"Cannot create offer"}') {
          Timer(Duration(seconds: 1), sendOMERequest);
        }
        onMessage(_decoder.convert(data));
      }, onDone: () async {
        print("OvenMediaServer stream is done");
        await close();
        if (onStreamCancel != null) {
          onStreamCancel!();
        }

        Timer(Duration(seconds: 1), () {
          if (AppState().getCurrentPage() == '/viewVideo') {
            if (AppState.refreshStream != null) {
              AppState.refreshStream!();
            }
          }
        });
      }, onError: (err) async {
        print("OvenMediaServer stream error: $err");
        await close();
        if (onStreamCancel != null) {
          onStreamCancel!();
        }

        Timer(Duration(seconds: 1), () {
          if (AppState().getCurrentPage() == '/viewVideo') {
            if (AppState.refreshStream != null) {
              AppState.refreshStream!();
            }
          }
        });
      }, cancelOnError: true);

      sendOMERequest();
    }).onError((error, stackTrace) async {
      print('Websocket of OvenMediaPlayer error: $error');
      await close();
      if (onStreamCancel != null) {
        onStreamCancel!();
      }
      Timer(Duration(seconds: 1), () {
        if (AppState().getCurrentPage() == '/viewVideo') {
          if (AppState.refreshStream != null) {
            AppState.refreshStream!();
          }
        }
      });

      return null;
    });
  }

  void sendOMERequest() {
    if (_channel?.closeCode != null) {
      return;
    }
    var request = Map();
    request["command"] = "request_offer";
    _channel?.sink.add(_encoder.convert(request));
  }

  void onMessage(Map<String, dynamic> mapData) async {
    switch (mapData['command']) {
      case 'offer':
        {
          _selfId = mapData['id'].toString();
          var peerId = mapData['peer_id'].toString();
          Map<String, dynamic> sdp = mapData['sdp'];
          var candidates = mapData['candidates'];

          await createSession(peerId: peerId, sdp: sdp, candidates: candidates);
        }
        break;
    }
  }

  Future<void> createSession(
      {required String peerId,
      required Map<String, dynamic> sdp,
      dynamic candidates}) async {
    _session = _session ?? Session(sid: _selfId, pid: peerId);
    _session!.pc = await createPeerConnection(<String, dynamic>{});

    _session!.pc.onTrack = (event) {
      if (event.track.kind == 'video') {
        onAddRemoteStream?.call(_session!, event.streams[0]);
      }
      if (event.track.kind == 'audio') {}
    };

    _session!.pc.onDataChannel = (channel) {
      _session!.dc = channel;
    };

    var remoteDescripton = RTCSessionDescription(sdp['sdp'], sdp['type']);
    await _session!.pc.setRemoteDescription(remoteDescripton);

    var localSdp = await _session!.pc.createAnswer();

    var answer = _encoder.convert({
      'id': int.parse(_selfId),
      'peer_id': int.parse(_session!.pid),
      'command': 'answer',
      'sdp': {'type': 'answer', 'sdp': localSdp.sdp},
    });

    _channel!.sink.add(answer);

    _session!.pc.setLocalDescription(localSdp);

    await addIceCandidate(_session!.pc, candidates);
  }

  Future<void> addIceCandidate(
      RTCPeerConnection pc, List<dynamic> candidates) async {
    for (int i = 0; i < candidates.length; i++) {
      var candidate = RTCIceCandidate(
          candidates[i]['candidate'], null, candidates[i]['sdpMLineIndex']);

      await pc.addCandidate(candidate);
    }
  }

  Future<void> close() async {
    if (_wasClosed == true) {
      return;
    }
    _wasClosed = true;

    if (_session?.pc.getRemoteStreams().isNotEmpty == true) {
      for (var stream in _session!.pc.getRemoteStreams()) {
        stream?.getTracks().forEach((track) async {
          await track.stop();
        });

        // try {
        //   stream.dispose();
        // } catch (exc) {
        //   print(exc.toString());
        // }
      }
    }

    try {
      await _session?.pc?.close();
    } catch (exc) {
      print(exc.toString());
    }
    try {
      await _session?.dc?.close();
    } catch (exc) {
      print(exc.toString());
    }
    try {
      await _channel?.sink?.close();
    } catch (exc) {
      print(exc.toString());
    }
    try {
      await _socket?.close();
    } catch (exc) {
      print(exc.toString());
    }

    _session = null;
    _socket = null;
  }
}
