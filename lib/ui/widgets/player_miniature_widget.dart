import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogabili_app/blocs/player/player_bloc.dart';
import 'package:jogabili_app/ui/constants/text_styles.dart';
import 'package:jogabili_app/ui/player/player_page.dart';
import 'package:marquee/marquee.dart';

class PlayerMiniature extends StatelessWidget {
  const PlayerMiniature({Key key}) : super(key: key);

  static final Color lightColor = Color(0xFF000000);
  static final Color darkColor = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(builder: (context, state) {
      if (state is PlayerPlaying) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlayerPage(
                          episode: state.episode,
                          bgColor: state.bgColor,
                          playerBloc: context.read<PlayerBloc>(),
                        ),
                    fullscreenDialog: true));
          },
          child: Container(
            height: 80,
            decoration: BoxDecoration(color: state.bgColor ?? Colors.white),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(state.episode.imageUrl))),
                    ),
                  ),
                ),
                Expanded(
                    flex: 6,
                    child: Container(
                      height: 80,
                      child: Marquee(
                        text: state.episode.title,
                        style: TextStyles.episodeTabTextStyle(
                            state.bgColor != null
                                ? ThemeData.estimateBrightnessForColor(
                                            state.bgColor) ==
                                        Brightness.light
                                    ? lightColor
                                    : darkColor
                                : lightColor),
                        blankSpace: 20,
                        startAfter: Duration(seconds: 3),
                        pauseAfterRound: Duration(seconds: 3),
                      ),
                    )),
                Expanded(
                    flex: 2,
                    child: IconButton(
                      onPressed: () {
                        context.read<PlayerBloc>().add(PlayerSwitch());
                      },
                      icon: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: state.bgColor != null
                            ? ThemeData.estimateBrightnessForColor(
                                        state.bgColor) ==
                                    Brightness.light
                                ? lightColor
                                : darkColor
                            : lightColor,
                      ),
                    ))
              ],
            ),
          ),
        );
      }
      return Container();
    });
  }
}
