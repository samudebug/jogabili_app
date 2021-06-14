import 'package:episodes_repository/episodes_repository.dart';
import 'package:flutter/material.dart';
import 'package:jogabili_app/blocs/episodes/episodes_bloc.dart';
import 'package:jogabili_app/ui/widgets/episode_card_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GamesPage extends StatefulWidget {
  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final _scrollController = ScrollController();
  EpisodesBloc _episodesBloc;
  List<Episode> episodes;
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
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax
                  ? state.episodes.length
                  : state.episodes.length + 1,
              itemBuilder: (context, index) {
                return index >= state.episodes.length
                    ? BottomLoader()
                    : EpisodeCard(
                        title: state.episodes[index].title,
                        subTitle: state.episodes[index].subTitle,
                        imageUrl: state.episodes[index].imageUrl,
                        pubDate: state.episodes[index].pubDate,
                        description: state.episodes[index].description,
                      );
              },
            ),
          ),
        );
      }
      return Container();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
