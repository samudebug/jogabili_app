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
  final Color bgColor;
  final Episode episode;
  PlayerPlaying(
      this.position, this.duration, this.isPlaying, this.bgColor, this.episode);

  PlayerPlaying copyWith(
      {Stream<Duration> position,
      Duration duration,
      bool isPlaying,
      Color color,
      Episode episode}) {
    return PlayerPlaying(
        position ?? this.position,
        duration ?? this.duration,
        isPlaying ?? this.isPlaying,
        color ?? this.bgColor,
        episode ?? this.episode);
  }

  @override
  // TODO: implement props
  List<Object> get props => [position, duration, isPlaying, bgColor, episode];
}
