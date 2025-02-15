import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'models/track.dart';

class Player extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Track> _playlist = [];
  int _currentTrackIndex = 0;
  bool _isPlaying = false;
  bool _isMuted = false;
  double _volume = 1.0; // Громкость по умолчанию (максимум)
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  List<Track> get playlist => _playlist;
  int get currentTrackIndex => _currentTrackIndex;
  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  double get volume => _volume;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  Stream<Duration> get positionStream => _audioPlayer.onPositionChanged;

  Player() {
    _audioPlayer.onPlayerComplete.listen((event) {
      next();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });
  }

  void setPlaylist(List<Track> playlist) {
    _playlist = playlist;
    notifyListeners();
  }

  void play() async {
    if (_playlist.isEmpty) return;
    await _audioPlayer.play(UrlSource(_playlist[_currentTrackIndex].url));
    _isPlaying = true;
    notifyListeners();
  }

  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void next() {
    if (_playlist.isEmpty) return;
    _currentTrackIndex = (_currentTrackIndex + 1) % _playlist.length;
    play();
    notifyListeners();
  }

  void previous() {
    if (_playlist.isEmpty) return;
    _currentTrackIndex = (_currentTrackIndex - 1 + _playlist.length) % _playlist.length;
    play();
    notifyListeners();
  }

  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void playTrack(int index) {
    if (index < 0 || index >= _playlist.length) return;
    _currentTrackIndex = index;
    play();
    notifyListeners();
  }

  void setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0); // Ограничиваем громкость от 0.0 до 1.0
    await _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  void toggleMute() async {
    _isMuted = !_isMuted;
    if (_isMuted) {
      await _audioPlayer.setVolume(0.0);
    } else {
      await _audioPlayer.setVolume(_volume);
    }
    notifyListeners();
  }

  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}