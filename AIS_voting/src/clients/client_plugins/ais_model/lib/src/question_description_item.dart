class QuestionDescriptionItem {
  String caption;
  String text;
  bool showOnStoreboard;
  bool showInReports;

  QuestionDescriptionItem(
      {this.caption, this.text, this.showOnStoreboard, this.showInReports});

  Map toJson() => {
        'caption': caption,
        'text': text,
        'showOnStoreboard': showOnStoreboard,
        'showInReports': showInReports,
      };

  QuestionDescriptionItem.fromJson(Map<String, dynamic> json)
      : caption = json['caption'],
        text = json['text'],
        showOnStoreboard = json['showOnStoreboard'] ?? true,
        showInReports = json['showInReports'] ?? true;

  @override
  String toString() {
    return caption + text;
  }
}
