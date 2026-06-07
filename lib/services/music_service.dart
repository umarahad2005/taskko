import 'package:audioplayers/audioplayers.dart';

import '../models/mood.dart';

/// Plays mind-refreshing music at the end of a focus session, chosen by the
/// user's current mood (SRS FR-9 break experience). Tracks are royalty-free
/// (SoundHelix, free to use). Robust to platforms without audio.
class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  final AudioPlayer _player = AudioPlayer();

  String _trackFor(Mood mood) {
    switch (mood) {
      case Mood.firedUp:
        return 'music/energetic.mp3';
      case Mood.chill:
      case Mood.drained:
        return 'music/calm.mp3';
      case Mood.focused:
        return 'music/focus.mp3';
    }
  }

  Future<void> playForMood(Mood mood) async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(_trackFor(mood)));
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }
}
