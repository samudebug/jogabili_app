import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class PodcastAudioHandler extends BaseAudioHandler {
  late AudioPlayer _player;
  PodcastAudioHandler() {
    _player = AudioPlayer();
  }

  @override
  Future<void> fastForward() {
    return this.seek(_player.position + Duration(seconds: 5));
  }

  @override
  Future<void> rewind() {
    return this.seek(_player.position - Duration(seconds: 5));
  }

  @override
  Future<void> seek(Duration position) {
    return _player.seek(position);
  }

  @override
  Future<void> play() async {
    playbackState.add(playbackState.value.copyWith(
        playing: true,
        controls: [
          MediaControl.rewind,
          MediaControl.pause,
          MediaControl.fastForward,
        ],
        systemActions: {MediaAction.seek, MediaAction.rewind, MediaAction.fastForward},
        processingState: AudioProcessingState.ready));
    return _player.play();
  }

  @override
  Future<void> pause() async {
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [
        MediaControl.rewind,
        MediaControl.play,
        MediaControl.fastForward,
      ],
      systemActions: {MediaAction.seek, MediaAction.rewind, MediaAction.fastForward},
    ));
    return _player.pause();
  }

  Future<Duration?> setUrl(
      String url, String imageUrl, String episodeTitle) async {
    playbackState.add(playbackState.value.copyWith(controls: [
      MediaControl.play,
      MediaControl.rewind,
      MediaControl.fastForward,
    ], systemActions: {
      MediaAction.seek,
      MediaAction.rewind, MediaAction.fastForward
    }, processingState: AudioProcessingState.loading));
    Duration? length = await _player.setUrl(url);
    MediaItem newItem = MediaItem(
        id: url,
        title: episodeTitle,
        artUri: Uri.parse(imageUrl),
        duration: length!);
    this.playMediaItem(newItem);
    mediaItem.add(newItem);
    return length;
  }

  bool get playing => playbackState.value.playing;

  Stream<bool> get playingStream => _player.playingStream;
  Stream<Duration> get positionStream => _player.positionStream;
}
