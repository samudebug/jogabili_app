part of 'episodes_bloc.dart';

@immutable
abstract class EpisodesState extends Equatable {
  const EpisodesState();
  @override
  List<Object> get props => [];
}

class EpisodesInitial extends EpisodesState {}

class EpisodesLoading extends EpisodesState {}

class EpisodesUpdating extends EpisodesState {}

class EpisodesReady extends EpisodesState {
  const EpisodesReady({required this.episodes, this.hasReachedMax = false});
  final List<Episode> episodes;
  final bool hasReachedMax;

  EpisodesReady copyWith(
      {List<Episode>? episodes, bool? hasReachedMax = false}) {
    return EpisodesReady(
        episodes: episodes ?? this.episodes,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object> get props => [episodes, hasReachedMax];
}
