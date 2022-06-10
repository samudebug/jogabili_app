import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:episodes_repository/episodes_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:jogabili_app/handlers/audio_player_handler.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  late PodcastAudioHandler _handler;
  PlayerBloc(this._handler) : super(PlayerInitial());

  @override
  Stream<PlayerState> mapEventToState(
    PlayerEvent event,
  ) async* {
    if (event is PlayerPlay) {
      yield mapPlayerPlayToState(event);
    } else if (event is PlayerLoaded) {
      yield mapPlayerLoadedToState(event);
    } else if (event is PlayerFail) {
      yield PlayerFailed();
    } else if (event is PlayerSwitch) {
      yield mapPlayerSwitchLoadedToState();
    } else if (event is PlayerJump) {
      yield mapPlayerJumpToState(event);
    }
  }

  PlayerState mapPlayerPlayToState(PlayerPlay event) {
    playAudio(event.episode, event.color);
    return PlayerLoading();
  }

  PlayerState mapPlayerLoadedToState(PlayerLoaded event) {
    _handler.positionStream.listen((position) {
      _handler.playbackState
          .add(_handler.playbackState.value.copyWith(updatePosition: position));
    });
    return PlayerPlaying(_handler.positionStream, event.duration,
        _handler.playingStream, _handler.playing, event.color, event.episode);
  }

  PlayerState mapPlayerSwitchLoadedToState() {
    if (state is PlayerPlaying) {
      if ((state as PlayerPlaying).isPlaying) {
        _handler.pause();
        return (state as PlayerPlaying).copyWith(isPlaying: false);
      } else {
        _handler.play();
        return (state as PlayerPlaying).copyWith(isPlaying: true);
      }
    }
    return (state as PlayerPlaying).copyWith(isPlaying: _handler.playing);
  }

  PlayerState mapPlayerJumpToState(PlayerJump event) {
    _handler.seek(event.position);
    return state;
  }

  Future<void> playAudio(Episode episode, Color color) async {
    try {
      Duration? duration = await _handler.setUrl(
          episode.audioUrl!, episode.imageUrl!, episode.title!);
      _handler.play();
      add(PlayerLoaded(duration!, episode, color));
    } catch (e) {
      print(e);
      add(PlayerFail());
    }
  }
}
