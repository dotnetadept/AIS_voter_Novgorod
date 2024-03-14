import 'package:ais_model/ais_model.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:operator_panel/Providers/AppState.dart';
import 'WebSocketConnection.dart';

class SoundPlayer with ChangeNotifier {
  static SoundPlayer _singleton;

  static Player _player;
  static bool _isOperatorActive;
  static bool _isStoreboardActive;
  static var _medias = Map<String, Media>();

  static SoundPlayer getInstance() {
    return _singleton;
  }

  static void init() {
    _singleton = SoundPlayer();
  }

  SoundPlayer() {
    _player = Player(configuration: PlayerConfiguration());
  }

  static void setVolume(double volume) {
    _player.setVolume(volume);
  }

  static Player getPlayer() {
    return _player;
  }

  static void setOperatorIsActive(bool isActive) {
    _isOperatorActive = isActive;
  }

  static void setStoreboardIsActive(bool isActive) {
    _isStoreboardActive = isActive;
  }

  static void loadSound(String path, String type) {
    _medias.putIfAbsent(type, () => Media(path));
  }

  static Future<void> playSoundByPath(String path) async {
    var sound = _medias.entries
        .firstWhere((element) => element.value.uri == path, orElse: () => null)
        ?.value;
    if (sound == null) {
      return;
    }

    var volume = AppState().getVolume();

    if (_isOperatorActive) {
      cancelSound();

      setVolume(volume);

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _player.open(sound);
      });
    }

    WebSocketConnection.getInstance().setSound(sound.uri, volume);
  }

  static void playSoundByType(String type) {
    var sound = _medias[type];
    if (sound == null) {
      return;
    }

    var volume = AppState().getVolume();

    if (_isOperatorActive) {
      cancelSound();

      setVolume(volume);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _player.open(sound);
        });
      });
    }

    WebSocketConnection.getInstance().setSound(sound.uri, volume);
  }

  static void playSignal(Signal signal, {bool isInternal = true}) {
    var media = _medias[signal?.id?.toString()];
    if (media == null) {
      return;
    }

    var volume = (AppState().getVolume() * signal.volume) / 100;

    if (_isOperatorActive) {
      cancelSound();
      setVolume(volume);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _player.open(Media(signal.soundPath));
      });
    }

    if (!isInternal) {
      WebSocketConnection.getInstance().setSound(signal.soundPath, volume);
    }
  }

  static bool playEndingSignal(Signal signal) {
    var result = false;

    var media = _medias[signal?.id?.toString()];

    if (media == null) {
      return result;
    }

    var volume = AppState().getVolume() * signal.volume / 100;

    if (_isOperatorActive) {
      cancelSound();
      setVolume(volume);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _player.open(Media(signal.soundPath));
      });

      result = true;
    }

    return result;
  }

  static void cancelSound() {
    if (_isOperatorActive == true) {
      _player.stop();
    }

    if (WebSocketConnection.getInstance().getIsOnline) {
      WebSocketConnection.getInstance()
          .setSound('cancel', AppState().getVolume());
    }
  }
}
