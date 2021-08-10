import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:episodes_repository/episodes_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  AudioPlayer player = AudioPlayer();
  PlayerBloc() : super(PlayerInitial());

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
    return PlayerPlaying(player.positionStream, event.duration, player.playing,
        event.color, event.episode);
  }

  PlayerState mapPlayerSwitchLoadedToState() {
    if (state is PlayerPlaying) {
      if ((state as PlayerPlaying).isPlaying)
        player.pause();
      else
        player.play();
    }
    return (state as PlayerPlaying).copyWith(isPlaying: player.playing);
  }

  PlayerState mapPlayerJumpToState(PlayerJump event) {
    player.seek(event.position);
    return state;
  }

  Future<void> playAudio(Episode episode, Color color) async {
    try {
      Duration duration = await player.setUrl(episode.audioUrl);
      player.play();
      add(PlayerLoaded(duration, episode, color));
    } catch (e) {
      print(e);
      add(PlayerFail());
    }
  }
}
