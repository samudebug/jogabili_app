part of 'episodes_bloc.dart';

@immutable
abstract class EpisodesEvent extends Equatable {
  const EpisodesEvent();

  @override
  List<Object> get props => [];
}

class LoadNewPage extends EpisodesEvent {}

class ClearEpisodes extends EpisodesEvent {}

class LoadEpisodesGames extends EpisodesEvent {
  const LoadEpisodesGames({this.page = 1});
  final int page;

  @override
  List<Object> get props => [page];
}

class LoadEpisodesNonGames extends EpisodesEvent {
  const LoadEpisodesNonGames({this.page = 1});

  final int page;

  @override
  List<Object> get props => [page];
}

class EpisodesLoaded extends EpisodesEvent {
  const EpisodesLoaded({required this.episodes});
  final List<Episode> episodes;

  @override
  List<Object> get props => [episodes];
}
