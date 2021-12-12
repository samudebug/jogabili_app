import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogabili_app/blocs/episodes/episodes_bloc.dart';
import 'package:jogabili_app/blocs/player/player_bloc.dart';
import 'package:jogabili_app/ui/games/games_page.dart';
import 'package:jogabili_app/ui/non_games/non_games_page.dart';
import 'package:jogabili_app/ui/widgets/player_miniature_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  List<String> _pageTitles = ["Games", "Não Games"];
  final List<Widget> children = [GamesPage(), NonGamesPage()];
  void onTabTapped(int index, EpisodesBloc bloc) {
    setState(() {
      _currentPage = index;
    });
    bloc.add(LoadNewPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_pageTitles[_currentPage]),
          ),
          backgroundColor: Colors.grey[200],
          bottomNavigationBar: BottomNavigationBar(
            onTap: (index) {
              return onTabTapped(index, context.read<EpisodesBloc>());
            },
            currentIndex: _currentPage,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.videogame_asset), label: "Games"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.wifi_tethering), label: "Não Games")
            ],
          ),
          body: Stack(
            children: [
              children[_currentPage],
              Align(alignment: Alignment.bottomCenter, child: PlayerMiniature())
            ],
          ),
        );
      },
    );
  }
}
