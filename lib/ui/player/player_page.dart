import 'package:audio_service/audio_service.dart';
import 'package:episodes_repository/episodes_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogabili_app/blocs/player/player_bloc.dart';
import 'package:jogabili_app/ui/constants/text_styles.dart';
import 'package:marquee/marquee.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage(
      {Key? key,
      required this.episode,
      required this.playerBloc,
      required this.bgColor})
      : super(key: key);
  final Episode episode;
  final PlayerBloc playerBloc;
  final Color bgColor;
  @override
  _PlayerPageState createState() =>
      _PlayerPageState(this.episode, this.playerBloc, this.bgColor);
}

class _PlayerPageState extends State<PlayerPage> {
  _PlayerPageState(this.episode, this.playerBloc, this.bgColor);
  final Episode episode;
  final PlayerBloc playerBloc;
  static final Color lightColor = Color(0xFF000000);
  static final Color darkColor = Color(0xFFFFFFFF);
  final Color bgColor;
  Color colorForTheme = lightColor;
  Color? reverseColorForTheme;
  Brightness? appBarBrightness;
  double sliderValue = 5;

  @override
  void initState() {
    super.initState();
    setBgColor();
  }

  void setBgColor() async {
    Color newBgColor = (await PaletteGenerator.fromImageProvider(
            NetworkImage(episode.imageUrl!)))
        .dominantColor!
        .color;

    setState(() {
      colorForTheme =
          ThemeData.estimateBrightnessForColor(bgColor) == Brightness.light
              ? lightColor
              : darkColor;
      appBarBrightness = ThemeData.estimateBrightnessForColor(bgColor);
      reverseColorForTheme =
          ThemeData.estimateBrightnessForColor(bgColor) == Brightness.light
              ? darkColor
              : lightColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayerState>(
      listener: (context, state) {
        if (state is PlayerFailed) {
          final snackBar = SnackBar(content: Text('Ocorreu um erro!'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          brightness: appBarBrightness,
          title: Container(
            height: 50,
            child: Marquee(
              text: episode.title!,
              style: TextStyles.episodeTitlePlayerTextStyle(colorForTheme),
              blankSpace: 20,
              startAfter: Duration(seconds: 3),
              pauseAfterRound: Duration(seconds: 3),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: colorForTheme,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Image(
                image: NetworkImage(episode.imageUrl!),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 15),
                child: _mediaButtons(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 2),
                child: BlocBuilder<PlayerBloc, PlayerState>(
                  builder: (context, state) {
                    if (state is PlayerPlaying)
                      return StreamBuilder<Duration>(
                          stream: state.position,
                          builder: (context, snapshot) {
                            if (snapshot.hasData)
                              return Slider(
                                value: snapshot.data!.inSeconds.toDouble(),
                                min: 0,
                                max: state.duration.inSeconds.toDouble(),
                                divisions:
                                    state.duration.inSeconds.toDouble() ~/ 5,
                                activeColor: colorForTheme,
                                inactiveColor: colorForTheme.withAlpha(127),
                                onChanged: (value) {
                                  context.read<PlayerBloc>().add(PlayerJump(
                                      Duration(seconds: value.toInt())));
                                },
                              );
                            return Slider(
                              value: 0,
                              min: 0,
                              max: 0,
                              divisions: 5,
                              activeColor: colorForTheme,
                              inactiveColor: colorForTheme.withAlpha(127),
                              onChanged: (value) {
                                setState(() {
                                  sliderValue = value;
                                });
                              },
                            );
                          });
                    return Slider(
                      value: 0,
                      min: 0,
                      max: 0,
                      divisions: 5,
                      activeColor: colorForTheme,
                      inactiveColor: colorForTheme.withAlpha(127),
                      onChanged: (value) {
                        setState(() {
                          sliderValue = value;
                        });
                      },
                    );
                  },
                ),
              ),
              BlocBuilder<PlayerBloc, PlayerState>(
                builder: (context, state) {
                  if (state is PlayerPlaying)
                    return _lengthInfo(state.position, state.duration);
                  return _lengthInfoStatic();
                },
              ),
              _tabWidget()
            ],
          ),
        ),
      ),
    );
  }

  Expanded _tabWidget() {
    List<Widget> tabs = [
      Tab(
        child: Text(
          "Descrição",
          style: TextStyles.episodeTabTextStyle(colorForTheme),
        ),
      ),
    ];
    List<Widget> content = [
      Container(
          child: Center(
        child: SingleChildScrollView(
          child: Text(episode.longDescription!,
              style: TextStyles.episodeLongDescriptionTextStyle(colorForTheme)),
        ),
      )),
    ];
    if (episode.links != null) {
      tabs.add(Tab(
        child: Text(
          "Links",
          overflow: TextOverflow.ellipsis,
          style: TextStyles.episodeTabTextStyle(colorForTheme),
        ),
      ));
      content.add(Container(
          child: ListView.builder(
        itemCount: episode.links!.length,
        itemBuilder: (context, index) {
          return TextButton(
              onPressed: () {
                launch(episode.links![index].linkUrl!);
              },
              child: Text(
                episode.links![index].title!,
                textAlign: TextAlign.start,
              ));
        },
      )));
    }

    if (episode.blocks != null) {
      tabs.add(Tab(
        child: Text(
          "Blocos",
          style: TextStyles.episodeTabTextStyle(colorForTheme),
        ),
      ));
      content.add(Container(
          child: Center(
        child: ListView.separated(
            itemBuilder: (context, index) {
              return ListTile(
                  onTap: () {
                    context.read<PlayerBloc>().add(PlayerJump(
                        timestampToDuration(
                            episode.blocks![index].timeStamp!)));
                  },
                  title: Container(
                    height: 50,
                    child: Marquee(
                      text:
                          "${episode.blocks![index].title} - ${episode.blocks![index].timeStamp} ",
                      style: TextStyles.episodeTabTextStyle(colorForTheme),
                      blankSpace: 20,
                      startAfter: Duration(seconds: 3),
                      pauseAfterRound: Duration(seconds: 3),
                    ),
                  ),
                  leading: Icon(Icons.play_arrow, color: colorForTheme));
            },
            separatorBuilder: (context, index) => Divider(
                  color: colorForTheme,
                ),
            itemCount: episode.blocks!.length),
      )));
    }

    return Expanded(
      child: DefaultTabController(
          length: tabs.length,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: TabBar(tabs: tabs),
              ),
              Expanded(
                child: TabBarView(children: content),
              )
            ],
          )),
    );
  }

  StreamBuilder _lengthInfo(Stream<Duration> position, Duration duration) {
    return StreamBuilder<Duration>(
        stream: position,
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Padding(
              padding: EdgeInsets.only(top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${snapshot.data!.inHours}:${fullNumber(snapshot.data!.inMinutes.remainder(60))}:${fullNumber(snapshot.data!.inSeconds.remainder(60))}",
                    style: TextStyles.episodeLengthTextStyle(colorForTheme),
                  ),
                  Text(
                    "${duration.inHours}:${duration.inMinutes.remainder(60)}:${(duration.inSeconds.remainder(60))}",
                    style: TextStyles.episodeLengthTextStyle(colorForTheme),
                  )
                ],
              ),
            );
          return Padding(
            padding: EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "0:00:00",
                  style: TextStyles.episodeLengthTextStyle(colorForTheme),
                ),
                Text(
                  "0:00:00",
                  style: TextStyles.episodeLengthTextStyle(colorForTheme),
                )
              ],
            ),
          );
        });
  }

  Widget _lengthInfoStatic() {
    return Padding(
      padding: EdgeInsets.only(top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "0:00:00",
            style: TextStyles.episodeLengthTextStyle(colorForTheme),
          ),
          Text(
            "0:00:00",
            style: TextStyles.episodeLengthTextStyle(colorForTheme),
          )
        ],
      ),
    );
  }

  Widget _mediaButtons() {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        if (state is PlayerPlaying) {
          return StreamBuilder<Duration>(
              stream: state.position,
              builder: (context, snapshot) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: IconButton(
                          onPressed: () {
                            context.read<PlayerBloc>().add(PlayerJump(Duration(
                                seconds: snapshot.data!.inSeconds - 5)));
                          },
                          icon: Icon(
                            Icons.fast_rewind,
                            color: colorForTheme,
                            size: 16,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            color: colorForTheme,
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        child: IconButton(
                            onPressed: () {
                              context.read<PlayerBloc>().add(PlayerSwitch());
                            },
                            icon: Icon(
                              state.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: reverseColorForTheme,
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: IconButton(
                          onPressed: () {
                            context.read<PlayerBloc>().add(PlayerJump(Duration(
                                seconds: snapshot.data!.inSeconds + 5)));
                          },
                          icon: Icon(
                            Icons.fast_forward,
                            color: colorForTheme,
                            size: 16,
                          )),
                    ),
                  ],
                );
              });
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.fast_rewind,
                    color: colorForTheme,
                    size: 16,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: colorForTheme,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.play_arrow,
                      color: reverseColorForTheme,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.fast_forward,
                    color: colorForTheme,
                    size: 16,
                  )),
            ),
          ],
        );
      },
    );
  }

  Duration timestampToDuration(String timestamp) {
    List<String> splitted = timestamp.split(":");
    return Duration(
        hours: int.parse(splitted[0]),
        minutes: int.parse(splitted[1]),
        seconds: int.parse(splitted[2]));
  }

  String fullNumber(int value) {
    if (value < 10) return "0$value";
    return value.toString();
  }
}
