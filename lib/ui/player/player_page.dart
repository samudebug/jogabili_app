import 'package:episodes_repository/episodes_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogabili_app/blocs/player/player_bloc.dart';
import 'package:jogabili_app/ui/constants/text_styles.dart';
import 'package:marquee/marquee.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:draggable_home/draggable_home.dart';

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

  final controller = DraggableScrollableController();
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    setBgColor();
  }

  void setBgColor() async {
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
    controller.addListener(() {
      print("Controller size ${controller.size}");
      if (double.parse(controller.size.toStringAsFixed(2)) == 0.10) {
        setState(() {
          isExpanded = false;
        });
      }
      if (double.parse(controller.size.toStringAsFixed(2)) == 0.90) {
        setState(() {
          isExpanded = true;
        });
      }
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
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarBrightness: appBarBrightness),
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
          child: LayoutBuilder(builder: (context, constraints) {
            return ConstrainedBox(
              constraints: constraints,
              child: Stack(
                children: [
                  if (isExpanded)
                    Positioned(
                      top: 0,
                      child: SizedBox(
                        height: 0.1 * constraints.maxHeight,
                        width: constraints.maxWidth,
                        child: BlocBuilder<PlayerBloc, PlayerState>(
                          builder: (context, state) {
                            if (state is PlayerPlaying) {
                              return Container(
                                height: 80,
                                decoration: BoxDecoration(color: state.bgColor),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Hero(
                                          tag: "podcast_image",
                                          child: Image(
                                            image:
                                                NetworkImage(episode.imageUrl!),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 6,
                                        child: Container(
                                          height: 80,
                                          child: Marquee(
                                            text: state.episode.title!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                    color: state.bgColor != null
                                                        ? ThemeData.estimateBrightnessForColor(
                                                                    state
                                                                        .bgColor) ==
                                                                Brightness.light
                                                            ? lightColor
                                                            : darkColor
                                                        : lightColor),
                                            blankSpace: 20,
                                            startAfter: Duration(seconds: 3),
                                            pauseAfterRound:
                                                Duration(seconds: 3),
                                          ),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: StreamBuilder<bool>(
                                          stream: state.playingStream,
                                          builder: (context, snapshot) =>
                                              IconButton(
                                            onPressed: () {
                                              context
                                                  .read<PlayerBloc>()
                                                  .add(PlayerSwitch());
                                            },
                                            icon: Icon(
                                              snapshot.data == null
                                                  ? Icons.play_arrow
                                                  : snapshot.data!
                                                      ? Icons.pause
                                                      : Icons.play_arrow,
                                              color: ThemeData
                                                          .estimateBrightnessForColor(
                                                              state.bgColor) ==
                                                      Brightness.light
                                                  ? lightColor
                                                  : darkColor,
                                            ),
                                          ),
                                        ))
                                  ],
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                    )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: "podcast_image",
                          child: Image(
                            image: NetworkImage(episode.imageUrl!),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: 50,
                            child: Marquee(
                              text: episode.title!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: colorForTheme),
                              blankSpace: 20,
                              startAfter: Duration(seconds: 3),
                              pauseAfterRound: Duration(seconds: 3),
                            ),
                          ),
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
                                          value: snapshot.data!.inSeconds
                                              .toDouble(),
                                          min: 0,
                                          max: state.duration.inSeconds
                                              .toDouble(),
                                          divisions: state.duration.inSeconds
                                                  .toDouble() ~/
                                              5,
                                          activeColor: colorForTheme,
                                          inactiveColor:
                                              colorForTheme.withAlpha(127),
                                          onChanged: (value) {
                                            context.read<PlayerBloc>().add(
                                                PlayerJump(Duration(
                                                    seconds: value.toInt())));
                                          },
                                        );
                                      return Slider(
                                        value: 0,
                                        min: 0,
                                        max: 0,
                                        divisions: 5,
                                        activeColor: colorForTheme,
                                        inactiveColor:
                                            colorForTheme.withAlpha(127),
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
                              return _lengthInfo(
                                  state.position, state.duration);
                            return _lengthInfoStatic();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: _mediaButtons(),
                        ),

                        // _tabWidget(),
                      ],
                    ),
                  Positioned.fill(
                      child: SizedBox.expand(
                    child: DraggableScrollableSheet(
                      snap: true,
                      controller: controller,
                      minChildSize: 0.1,
                      maxChildSize: 0.9,
                      initialChildSize: 0.1,
                      builder: (context, scrollController) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          child: Container(
                              color: bgColor,
                              height: 0.9 * constraints.maxHeight,
                              width: double.infinity,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: Divider(
                                      thickness: 5,
                                    ),
                                  ),
                                  _tabWidget()
                                ],
                              )),
                        );
                      },
                    ),
                  ))
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Expanded _tabWidget() {
    List<Widget> tabs = [
      Tab(
        child: Text(
          "Descrição",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: colorForTheme),
        ),
      ),
    ];
    List<Widget> content = [
      Container(
          child: Center(
        child: SingleChildScrollView(
          child: Text(episode.longDescription!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorForTheme)),
        ),
      )),
    ];
    if (episode.links != null) {
      tabs.add(Tab(
        child: Text(
          "Links",
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: colorForTheme),
        ),
      ));
      content.add(Container(
          child: ListView.builder(
        itemCount: episode.links!.length,
        itemBuilder: (context, index) {
          return TextButton(
              onPressed: () {
                launchUrl(Uri.parse(episode.links![index].linkUrl!));
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
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: colorForTheme),
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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: colorForTheme),
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
                child: TabBar(
                  tabs: tabs,
                  onTap: ((value) {
                    controller.animateTo(
                      0.9,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                    );
                  }),
                ),
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
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: colorForTheme),
                  ),
                  Text(
                    "${duration.inHours}:${fullNumber(duration.inMinutes.remainder(60))}:${fullNumber(duration.inSeconds.remainder(60))}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: colorForTheme),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: colorForTheme),
                ),
                Text(
                  "0:00:00",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: colorForTheme),
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
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: colorForTheme),
          ),
          Text(
            "0:00:00",
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: colorForTheme),
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
                        child: StreamBuilder<bool>(
                          stream: state.playingStream,
                          builder: (context, snapshot) => IconButton(
                              onPressed: () {
                                context.read<PlayerBloc>().add(PlayerSwitch());
                              },
                              icon: Icon(
                                snapshot.data == null
                                    ? Icons.play_arrow
                                    : snapshot.data!
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                color: reverseColorForTheme,
                              )),
                        ),
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

class MiniPlayerExpanded extends StatelessWidget {
  const MiniPlayerExpanded({
    Key? key,
    required this.bgColor,
    required this.episode,
    required this.lightColor,
    required this.darkColor,
  }) : super(key: key);

  final Color bgColor;
  final Episode episode;
  final Color lightColor;
  final Color darkColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(builder: (context, state) {
      if (state is PlayerPlaying) {
        return Container(
          height: 80,
          decoration: BoxDecoration(color: bgColor),
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
                            image: NetworkImage(episode.imageUrl!))),
                  ),
                ),
              ),
              Expanded(
                  flex: 6,
                  child: Container(
                    height: 80,
                    child: Marquee(
                      text: episode.title!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: bgColor != null
                              ? ThemeData.estimateBrightnessForColor(bgColor) ==
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
                  child: StreamBuilder<bool>(
                    stream: state.playingStream,
                    builder: (context, snapshot) => IconButton(
                      onPressed: () {
                        context.read<PlayerBloc>().add(PlayerSwitch());
                      },
                      icon: Icon(
                        snapshot.data == null
                            ? Icons.play_arrow
                            : snapshot.data!
                                ? Icons.pause
                                : Icons.play_arrow,
                        color: ThemeData.estimateBrightnessForColor(bgColor) ==
                                Brightness.light
                            ? lightColor
                            : darkColor,
                      ),
                    ),
                  ))
            ],
          ),
        );
      }
      return Container();
    });
  }
}
