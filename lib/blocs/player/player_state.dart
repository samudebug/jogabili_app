part of 'player_bloc.dart';

abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerLoading extends PlayerState {}

class PlayerFailed extends PlayerState {}

class PlayerPlaying extends PlayerState {
  final Stream<Duration> position;
  final Duration duration;
  final bool isPlaying;
  final Stream<bool> playingStream;
  final Color bgColor;
  final Episode episode;
  PlayerPlaying(this.position, this.duration, this.playingStream,
      this.isPlaying, this.bgColor, this.episode);

  PlayerPlaying copyWith(
      {Stream<Duration>? position,
      Duration? duration,
      Stream<bool>? playingStream,
      bool? isPlaying,
      Color? color,
      Episode? episode}) {
    return PlayerPlaying(
        position ?? this.position,
        duration ?? this.duration,
        playingStream ?? this.playingStream,
        isPlaying ?? this.isPlaying,
        color ?? this.bgColor,
        episode ?? this.episode);
  }

  @override
  List<Object> get props => [position, duration, isPlaying, bgColor, episode];
}
