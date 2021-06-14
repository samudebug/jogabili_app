class Episode {
  String title;
  String description;
  String subTitle;
  String imageUrl;
  String pubDate;
  String type;

  Episode(
      {this.title,
      this.description,
      this.subTitle,
      this.imageUrl,
      this.pubDate,
      this.type});

  Episode.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    subTitle = json['subTitle'];
    imageUrl = json['imageUrl'];
    pubDate = json['pubDate'];
    type = json['type'];
  }
}
