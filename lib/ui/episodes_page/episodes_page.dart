import 'package:flutter/material.dart';
import 'package:jogabili_app/blocs/episodes/episodes_bloc.dart';
import 'package:jogabili_app/ui/widgets/episode_card_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EpisodesPage extends StatefulWidget {
  
  @override
  _EpisodesPageState createState() => _EpisodesPageState();
}

class _EpisodesPageState extends State<EpisodesPage> {
  final _scrollController = ScrollController();
  late EpisodesBloc _episodesBloc;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _episodesBloc = context.read<EpisodesBloc>();
    _episodesBloc.add(LoadEpisodesGames());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpisodesBloc, EpisodesState>(builder: (context, state) {
      if (state is EpisodesInitial || state is EpisodesLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      if (state is EpisodesReady) {
        return Center(
          child: Container(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<EpisodesBloc>().add(ClearEpisodes());
                context.read<EpisodesBloc>().add(LoadEpisodesGames());
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.hasReachedMax
                    ? state.episodes.length
                    : state.episodes.length + 1,
                itemBuilder: (context, index) {
                  return index >= state.episodes.length
                      ? BottomLoader()
                      : EpisodeCard(
                          episode: state.episodes[index],
                        );
                },
              ),
            ),
          ),
        );
      }
      return Container();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _episodesBloc.add(LoadEpisodesGames());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
    );
  }
}
