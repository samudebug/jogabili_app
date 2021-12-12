import 'dart:convert';

class Episode {
  String? title;
  String? description;
  String? subTitle;
  String? imageUrl;
  String? pubDate;
  String? type;
  String? longDescription;
  List<Link>? links;
  List<Block>? blocks;
  String? audioUrl;

  Episode(
      {this.title,
      this.description,
      this.subTitle,
      this.imageUrl,
      this.pubDate,
      this.type,
      this.longDescription,
      this.audioUrl});

  Episode.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    subTitle = json['subTitle'];
    imageUrl = json['imageUrl'];
    pubDate = json['pubDate'];
    type = json['type'];
    longDescription = json['longDescription'];
    audioUrl = json['audioUrl'];
    if (json['links'] != null) {
      links = (json['links'] as List<dynamic>)
          .map((e) => Link.fromJson(e))
          .toList();
    }
    if (json['blocks'] != null) {
      blocks = (json['blocks'] as List<dynamic>)
          .map((e) => Block.fromJson(e))
          .toList();
    }
  }
}

class Link {
  String? title;
  String? linkUrl;

  Link({this.title, this.linkUrl});

  Link.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    linkUrl = json['linkUrl'];
  }
}

class Block {
  String? timeStamp;
  String? title;

  Block({this.timeStamp, this.title});

  Block.fromJson(Map<String, dynamic> json) {
    timeStamp = json['timestamp'];
    title = json['title'];
  }
}
