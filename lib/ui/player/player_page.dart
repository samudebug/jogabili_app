import 'package:episodes_repository/episodes_repository.dart';
import 'package:flutter/material.dart';
import 'package:jogabili_app/ui/constants/text_styles.dart';
import 'package:marquee/marquee.dart';
import 'package:palette_generator/palette_generator.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key key, this.episode}) : super(key: key);
  final Episode episode;
  @override
  _PlayerPageState createState() => _PlayerPageState(this.episode);
}

class _PlayerPageState extends State<PlayerPage> {
  _PlayerPageState(this.episode);
  final Episode episode;
  final Color lightColor = Color(0xFF000000);
  final Color darkColor = Color(0xFFFFFFFF);
  Color bgColor;
  Color colorForTheme;
  Color reverseColorForTheme;
  Brightness appBarBrightness;
  double sliderValue = 5;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setBgColor();
  }

  void setBgColor() async {
    Color newBgColor = (await PaletteGenerator.fromImageProvider(
            NetworkImage(episode.imageUrl)))
        .dominantColor
        .color;

    setState(() {
      bgColor = newBgColor;
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
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        brightness: appBarBrightness,
        title: Container(
          height: 50,
          child: Marquee(
            text: episode.title,
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
              image: NetworkImage(episode.imageUrl),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 15),
              child: Row(
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 2),
              child: Slider(
                value: sliderValue,
                min: 0,
                max: 15,
                divisions: 5,
                activeColor: colorForTheme,
                inactiveColor: colorForTheme.withAlpha(127),
                onChanged: (value) {
                  print(value);
                  setState(() {
                    sliderValue = value;
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "4:36:15",
                    style: TextStyles.episodeLengthTextStyle(colorForTheme),
                  ),
                  Text(
                    "7:57:40",
                    style: TextStyles.episodeLengthTextStyle(colorForTheme),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
