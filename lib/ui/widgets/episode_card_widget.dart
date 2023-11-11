import 'package:episodes_repository/episodes_repository.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogabili_app/blocs/player/player_bloc.dart';
import 'package:jogabili_app/ui/constants/colors.dart';
import 'package:jogabili_app/ui/player/player_page.dart';
import 'package:palette_generator/palette_generator.dart';
import '../constants/text_styles.dart';

class EpisodeCard extends StatelessWidget {
  EpisodeCard({required this.episode});

  final Episode episode;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ExpandableNotifier(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5), topRight: Radius.circular(5))),
          child: Card(
              child: Expandable(
            collapsed: Builder(
              builder: (context) {
                return buildCollapsed(context);
              },
            ),
            expanded: Builder(
              builder: (context) {
                return buildExpanded(context);
              },
            ),
          )),
        ),
      ),
    );
  }

  Container buildExpanded(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: bannerAndTitle(context),
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 8), child: dateAndPlay(context)),
          subTitleWidget(context),
          Center(
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_up,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                var controller =
                    ExpandableController.of(context, required: true);
                controller!.toggle();
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              episode.title!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              episode.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        ],
      ),
    );
  }

  Container buildCollapsed(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: bannerAndTitle(context),
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 8), child: dateAndPlay(context)),
          subTitleWidget(context),
          Center(
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                var controller =
                    ExpandableController.of(context, required: true);
                controller!.toggle();
              },
            ),
          )
        ],
      ),
    );
  }

  Padding subTitleWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 9,
            child: Text(
              episode.subTitle!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Padding dateAndPlay(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(
                          episode.pubDate!,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      )
                    ],
                  ),
                ),
                Text(episode.category!, style: Theme.of(context).textTheme.titleSmall,)
              ],
            ),
          ),
          /*
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: Color(0xFFFFEB3B),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PlayerPage(
                            episode: episode,
                          ),
                      fullscreenDialog: true));
                },
                icon: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                )),
          )*/
          Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: Color(0xFFFFEB3B),
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: IconButton(
                  onPressed: () async {
                    Color newBgColor =
                        (await PaletteGenerator.fromImageProvider(
                                NetworkImage(episode.imageUrl!)))
                            .dominantColor!
                            .color;
                    context
                        .read<PlayerBloc>()
                        .add(PlayerPlay(episode, newBgColor));
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlayerPage(
                                  episode: episode,
                                  bgColor: newBgColor,
                                  playerBloc: context.read<PlayerBloc>(),
                                ),
                            fullscreenDialog: true));
                  },
                  icon: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ))),
        ],
      ),
    );
  }

  Container bannerAndTitle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5), topRight: Radius.circular(5))),
      height: 230,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(episode.imageUrl!))),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black, Colors.transparent])),
              child: Text(episode.title!,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start),
            ),
          ),
        ],
      ),
    );
  }
}
