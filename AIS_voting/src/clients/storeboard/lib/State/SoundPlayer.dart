import 'package:ais_model/ais_model.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'AppState.dart';

class SoundPlayer with ChangeNotifier {
  static SoundPlayer _singleton;

  static Player _player;
  static bool _isActive;
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

  static void setIsActive(bool isActive) {
    _isActive = isActive;
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

    var volume = AppState().getServerState().soundVolume;

    if (_isActive) {
      cancelSound();

      setVolume(volume);

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _player.open(sound);
      });
    }
  }

  static void playSoundByType(String type) {
    var sound = _medias[type];
    if (sound == null) {
      return;
    }

    if (_isActive) {
      cancelSound();

      setVolume(AppState().getServerState().soundVolume);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _player.open(sound);
        });
      });
    }
  }

  static void playSignal(Signal signal) {
    var media = _medias[signal?.id?.toString()];
    if (media == null) {
      return;
    }

    var volume =
        (AppState().getServerState().soundVolume * signal.volume) / 100;

    if (_isActive) {
      cancelSound();
      setVolume(volume);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _player.open(Media(signal.soundPath));
      });
    }
  }

  static bool playEndingSignal(Signal signal) {
    var result = false;

    var media = _medias[signal?.id?.toString()];

    if (media == null) {
      return result;
    }

    var volume = AppState().getServerState().soundVolume * signal.volume / 100;

    if (_isActive) {
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
    if (_isActive == true) {
      _player.stop();
    }
  }
}
