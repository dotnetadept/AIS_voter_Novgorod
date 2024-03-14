class QuestionDescriptionItem {
  String caption;
  String text;

  QuestionDescriptionItem({this.caption, this.text});

  Map toJson() => {
        'caption': caption,
        'text': text,
      };

  QuestionDescriptionItem.fromJson(Map<String, dynamic> json)
      : caption = json['caption'],
        text = json['text'];
}
