import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:jogabili_app/ui/constants/colors.dart';
import '../constants/text_styles.dart';

class EpisodeCard extends StatelessWidget {
  EpisodeCard(
      {@required this.title,
      @required this.subTitle,
      @required this.imageUrl,
      @required this.pubDate,
      @required this.description});

  final String title;
  final String subTitle;
  final String imageUrl;
  final String pubDate;
  final String description;
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
            child: bannerAndTitle(),
          ),
          Padding(padding: EdgeInsets.only(bottom: 8), child: date()),
          subTitleWidget(),
          Center(
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_up,
                color: Color(0x80000000),
              ),
              onPressed: () {
                var controller =
                    ExpandableController.of(context, required: true);
                controller.toggle();
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyles.episodeBlackTitleStyle,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              description,
              style: TextStyles.episodeDescriptionTextStyle,
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
            child: bannerAndTitle(),
          ),
          Padding(padding: EdgeInsets.only(bottom: 8), child: date()),
          subTitleWidget(),
          Center(
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Color(0x80000000),
              ),
              onPressed: () {
                var controller =
                    ExpandableController.of(context, required: true);
                controller.toggle();
              },
            ),
          )
        ],
      ),
    );
  }

  Padding subTitleWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 9,
            child: Text(
              subTitle,
              style: TextStyles.subTitleTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Padding date() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    color: ColorsConstants.dateColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: Text(
                    pubDate,
                    style: TextStyles.dateTextStyle,
                  ),
                )
              ],
            ),
          ),
          FloatingActionButton(
            child: Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
            mini: false,
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Container bannerAndTitle() {
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
                      fit: BoxFit.fill, image: NetworkImage(imageUrl))),
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
              child: Text(title,
                  style: TextStyles.episodeTitleStyle,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start),
            ),
          ),
        ],
      ),
    );
  }
}
