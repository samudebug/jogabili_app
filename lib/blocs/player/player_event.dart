part of 'player_bloc.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object> get props => [];
}

class PlayerPlay extends PlayerEvent {
  final Episode episode;
  final Color color;
  const PlayerPlay(this.episode, this.color);

  @override
  // TODO: implement props
  List<Object> get props => [episode, color];
}

class PlayerLoaded extends PlayerEvent {
  final Duration duration;
  final Episode episode;
  final Color color;
  const PlayerLoaded(this.duration, this.episode, this.color);

  @override
  // TODO: implement props
  List<Object> get props => [this.duration, this.episode, this.color];
}

class PlayerSwitch extends PlayerEvent {}

class PlayerJump extends PlayerEvent {
  final Duration position;

  const PlayerJump(this.position);

  @override
  // TODO: implement props
  List<Object> get props => [this.position];
}

class PlayerFail extends PlayerEvent {}
