import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:episodes_repository/episodes_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'episodes_event.dart';
part 'episodes_state.dart';

class EpisodesBloc extends Bloc<EpisodesEvent, EpisodesState> {
  EpisodesBloc({required this.episodesRepository}) : super(EpisodesInitial());

  final EpisodesRepository episodesRepository;

  @override
  Stream<EpisodesState> mapEventToState(
    EpisodesEvent event,
  ) async* {
    if (event is LoadEpisodesGames) {
      yield await _fetchEpisodesGames(state);
    } else if (event is LoadEpisodesNonGames) {
      yield await _fetchNonGamesEpisodes(state);
    } else if (event is LoadNewPage) {
      add(ClearEpisodes());
      yield EpisodesLoading();
    } else if (event is ClearEpisodes) {
      yield _clearEpisodes(state);
    }
  }

  EpisodesState _clearEpisodes(EpisodesState state) {
      return EpisodesInitial();
    
  }

  Future<EpisodesState> _fetchEpisodesGames(EpisodesState state) async {
    if (state is EpisodesReady) {
      if (state.hasReachedMax) {
        return state.copyWith(hasReachedMax: true);
      }
      if (state.episodes[0].type == "non-games") {
        return EpisodesReady(
            episodes: await episodesRepository.getGamesEpisodes());
      }
      double pageDouble = (state.episodes.length / 10) + 1;
      int page = pageDouble.floor();
      List<Episode> episodeList =
          await episodesRepository.getGamesEpisodes(page: page);
      return state.copyWith(
          episodes: List.of(state.episodes)..addAll(episodeList));
    }
    return EpisodesReady(episodes: await episodesRepository.getGamesEpisodes());
  }

  Future<EpisodesState> _fetchNonGamesEpisodes(EpisodesState state) async {
    if (state is EpisodesReady) {
      if (state.hasReachedMax) {
        return state..copyWith(episodes: state.episodes);
      }
      if (state.episodes[0].type == "games") {
        return EpisodesReady(
            episodes: await episodesRepository.getNonGamesEpisodes());
      }
      double pageDouble = (state.episodes.length / 10) + 1;
      int page = pageDouble.floor();
      print(page);
      List<Episode> episodeList = await episodesRepository.getNonGamesEpisodes(
          page: ((state.episodes.length / 10) + 1).floor());

      return state.copyWith(
          episodes: List.of(state.episodes)..addAll(episodeList));
    }
    return EpisodesReady(
        episodes: await episodesRepository.getNonGamesEpisodes());
  }
}
